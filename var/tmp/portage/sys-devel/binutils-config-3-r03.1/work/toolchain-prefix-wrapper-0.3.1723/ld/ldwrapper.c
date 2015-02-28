/*
 * Copyright 1999-2013 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * Authors: Fabian Groffen <grobian@gentoo.org>
 *          Michael Haubenwallner <haubi@gentoo.org>
 * based on the work of gcc wrapper done by:
 * Martin Schlemmer <azarah@gentoo.org>
 * Mike Frysinger <vapier@gentoo.org>
 */

#include <config.h>
#include <stringutil.h>
#include <textfile.h>

#include "binutils-config.h"
#include "ldplugin.h"
#include "aixplugin.h"
#include "gnuplugin.h"
#include "hpuxplugin.h"
#include "darwinplugin.h"
#include "solarisplugin.h"

#define _REENTRANT
#if !defined(_GNU_SOURCE)
#define _GNU_SOURCE
#endif

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <unistd.h>
#include <sys/wait.h>
#include <libgen.h>
#include <string.h>
#include <stdarg.h>
#include <errno.h>

#define BINUTILS_CONFIG    GENTOO_PORTAGE_EPREFIX "/usr/bin/binutils-config" /* host */
#define ENVD_BASE_BINUTILS GENTOO_PORTAGE_EPREFIX "/etc/env.d/binutils/"     /* host */

#define dprintf if (DEBUG()) fprintf

typedef struct _LdWrapperData {
	String* name; /* basename(argv[0]), mainly for diagnostics */
	struct stat arg0stat; /* stat(argv[0]) */

	String* bin; /* the target binary to be executed (on host) */

	StringList* envpath;
	String* _ctarget_binutilsbin_; /* cached string "/${CTARGET}/binutils-bin/" */

	LdPluginIn pluginIn;
} LdWrapperData;

static inline void wrapper_exit(char *msg, ...)
{
	va_list args;
	fprintf(stderr, "binutils-config error: ");
	va_start(args, msg);
	vfprintf(stderr, msg, args);
	va_end(args);
	exit(1);
}

/* create the string "/${CTARGET}/binutils-bin/",
 * as this is used a few times.
 */
static inline void setup_ctarget_binutilsbin(LdWrapperData *data)
{
	if (data->_ctarget_binutilsbin_ == NULL) {
		/* cache the string "/${CTARGET}/binutils-bin/" */
		data->_ctarget_binutilsbin_ = StringCreateConcat("/", 1
			, StringGetBuffer(data->pluginIn.target.triplet)
			, StringGetLength(data->pluginIn.target.triplet)
			, "/binutils-bin/", strlen("/binutils-bin/")
		, NULL);
		if (data->_ctarget_binutilsbin_ == NULL) {
			wrapper_exit("%s wrapper: %s\n",
				StringGetBuffer(data->name), strerror(errno));
		}
	}
	return;
}

/* check_for_binutils checks in path for the file we are seeking
 * it returns 1 if found (with data->bin setup), 0 if not
 */
static inline int check_for_binutils(String const * path, LdWrapperData *data)
{
	struct stat sbuf;
	int result;
	String* search;
	char const *str;
	char const *path_buffer;
	int path_len;

	/* check possible binary in path that
	 * 1) it is in a "/${CTARGET}/binutils-bin/" directory
	 * ...
	 */
	path_buffer = StringGetBuffer(path);
	path_len = StringGetLength(path);
	str = strstr(path_buffer, StringGetBuffer(data->_ctarget_binutilsbin_));
	if (str == NULL
	 || (path_len >= 0
	  && (str + StringGetLength(data->_ctarget_binutilsbin_)) > (path_buffer + path_len)
	 )
	) {
		/* not found, or found behind end of path indicated by path_len */
		return 0;
	}

	search = StringCreateConcat(path_buffer, path_len
		, "/", 1
		, StringGetBuffer(data->name), StringGetLength(data->name)
	, NULL);
	if (search == NULL) {
		wrapper_exit("%s wrapper: %s\n",
			StringGetBuffer(data->name), strerror(errno));
	}

	str = StringGetBuffer(search);

	/* ...
	 * 2) and it exist and is a regular file,
	 * 3) and it is not the wrapper itself by filesystem
	 */
	result = stat(str, &sbuf);
	if ((result == 0)
	 && ((sbuf.st_mode & S_IFREG) || (sbuf.st_mode & S_IFLNK))
	 && ((sbuf.st_dev != data->arg0stat.st_dev) || (sbuf.st_ino != data->arg0stat.st_ino))
	) {
		data->bin = search;
		search = NULL;
		return 1;
	}

	search = StringDestroy(search);
	return 0;
}

static inline int find_binutils_in_path(LdWrapperData *data)
{
	int i, pathcount;

	if (data->envpath == NULL) return 0;

	/* Find the first file with suitable name in PATH.  The idea here is
	 * that we do not want to bind ourselfs to something static like the
	 * default profile, or some odd environment variable, but want to be
	 * able to build something with a non default binutils by just tweaking
	 * the PATH ... */
	pathcount = StringListGetSize(data->envpath);
	for(i = 0; i < pathcount; i++) {
		String const * token = StringListGetString(data->envpath, i);
		if (token == NULL || StringGetLength(token) <= 0) {
			continue;
		}
		if (check_for_binutils(token, data)) {
			return 1;
		}
	}

	return 0;
}

/* read the value from some shell line setting a specific variable,
 * drop leading and trailing whitespaces and quotation marks.
 * returns NULL if line does not set expected variable.
 * returns String containing the value for expected variable.
 */
static inline String* parseline_shellvariable(LdWrapperData* data,
		char const *variable, int varlen, char const *line, int linelen)
{
	String* rv;

	if (linelen < 0) linelen = strlen(line);
	if (varlen < 0) varlen = strlen(variable);

	/* skip leading blanks */
	while(linelen > 0 && (*line == ' ' || *line == '\t' || *line == '\n')) {
		line++;
		linelen--;
	}

	if (linelen <= varlen
	 || strncmp(line, variable, varlen) != 0
	 || line[varlen] != '='
	) {
		/* this line does not set expected variable */
		return NULL;
	}

	line += varlen+1;
	linelen -= varlen+1;

	/* skip string delimiters */
	while(linelen > 0 && (*line == '\'' || *line == '\"')) {
		line++;
		linelen--;
	}

	/* skip string end delimiters and trailing blanks */
	while(linelen > 0
	   && (line[linelen-1] == '\''
		|| line[linelen-1] == '\"'
		|| line[linelen-1] == ' '
		|| line[linelen-1] == '\t'
		|| line[linelen-1] == '\n'
	   )
	) {
		linelen--;
	}

	rv = StringCreateConcat(line, linelen, NULL);
	if (rv == NULL) {
		wrapper_exit("%s wrapper: %s\n",
			StringGetBuffer(data->name), strerror(errno));
	}
	return rv;
}

/* find_binutils_in_envd parses /etc/env.d/binutils/config-${CTARGET} to get
 * current BVER, then tries to parse /etc/env.d/binutils/${CTARGET}-${BVER}
 * to extract PATH, which is set to the current binutils' bin directory ...
 */
static inline int find_binutils_in_envd(LdWrapperData *data)
{
	Textfile* envfile = NULL;
	String const * thisline;
	String* currentBVER = NULL;
	String* bindir = NULL;
	int rv = 0;

	envfile = TextfileOpenConcatName(ENVD_BASE_BINUTILS, strlen(ENVD_BASE_BINUTILS),
		"config-", strlen("config-"),
		StringGetBuffer(data->pluginIn.target.triplet),
		StringGetLength(data->pluginIn.target.triplet),
	NULL);
	if (envfile == NULL && errno != ENOENT) {
		wrapper_exit("%s wrapper: %s\n",
			StringGetBuffer(data->name), strerror(errno));
	}
	if (envfile == NULL) {
		return 0;
	}

	/* read current binutils version:
	 * /etc/env.d/binutils/config-${CTARGET} must contain this line:
	 * CURRENT=${BVER}
	 */
	while(TextfileReadLine(envfile) > 0) {
		thisline = TextfileGetCurrentLine(envfile);
		currentBVER = parseline_shellvariable(data, "CURRENT", strlen("CURRENT"),
				StringGetBuffer(thisline), StringGetLength(thisline));
		if (currentBVER != NULL) {
			break;
		}
	}

	envfile = TextfileClose(envfile);
	if (currentBVER == NULL) {
		/* /etc/env.d/binutils/config-${CTARGET} does not contain any CURRENT= */
		return 0;
	}

	/* construct path to binutils:
	 * CHOST == CTARGET: PATH=/gentoo/portage/host.eprefix/usr/${CHOST}/binutils-bin/${BVER}
	 * CHOST != CTARGET: PATH=/gentoo/portage/host.eprefix/usr/${CHOST}/${CTARGET}/binutils-bin/${BVER}
	 */
	if (data->pluginIn.isCrossTriplet) {
		bindir = StringCreateConcat(
			GENTOO_PORTAGE_EPREFIX, strlen(GENTOO_PORTAGE_EPREFIX),
			"/usr/", strlen("/usr/"),
			StringGetBuffer(data->pluginIn.host.triplet),
			StringGetLength(data->pluginIn.host.triplet),
			StringGetBuffer(data->_ctarget_binutilsbin_),
				StringGetLength(data->_ctarget_binutilsbin_),
			StringGetBuffer(currentBVER), StringGetLength(currentBVER),
		NULL);
	} else {
		bindir = StringCreateConcat(
			GENTOO_PORTAGE_EPREFIX, strlen(GENTOO_PORTAGE_EPREFIX),
			"/usr", strlen("/usr"),
			StringGetBuffer(data->_ctarget_binutilsbin_),
				StringGetLength(data->_ctarget_binutilsbin_),
			StringGetBuffer(currentBVER), StringGetLength(currentBVER),
		NULL);
	}
	if (bindir == NULL) {
		wrapper_exit("%s wrapper: %s\n",
			StringGetBuffer(data->name), strerror(errno));
	}
	StringDestroy(currentBVER);

	if (check_for_binutils(bindir, data)) {
		rv = 1;
	}

	StringDestroy(bindir);

	return rv;
}

static inline void find_wrapper_binutils(LdWrapperData *data)
{
	FILE *inpipe = NULL;
	String* binpath_command;
	char str[MAXPATHLEN + 1];
	char const* env = getenv("BINUTILS_CONFIG_LD");
	
	if (env != NULL && *env != '\0') {
		/* as we do linking during binutils-config,
		 * we need some working ld-wrapper for gcc,
		 * but the old one may be configured for the now unmerged ld.
		 */
		data->bin = StringCreateConcat(env, -1, NULL);
		if (data->bin == NULL) {
			wrapper_exit("%s wrapper: %s\n",
				StringGetBuffer(data->name), strerror(errno));
		}
		return;
	}

	setup_ctarget_binutilsbin(data);

	if (find_binutils_in_path(data))
		return;

	if (find_binutils_in_envd(data))
		return;

	/* Only our wrapper is in PATH, so
	   get the CC path using binutils-config and
	   execute the real binary in there... */
	binpath_command = StringCreateConcat(BINUTILS_CONFIG, strlen(BINUTILS_CONFIG),
		" --get-bin-path ", strlen(" --get-bin-path "),
		StringGetBuffer(data->pluginIn.target.triplet),
		StringGetLength(data->pluginIn.target.triplet),
	NULL);
	if (binpath_command == NULL) {
		wrapper_exit("%s wrapper: %s\n",
			StringGetBuffer(data->name), strerror(errno));
	}
	inpipe = popen(StringGetBuffer(binpath_command), "r");
	if (inpipe == NULL) {
		wrapper_exit("%s wrapper: could not open pipe: %s\n",
			StringGetBuffer(data->name), strerror(errno));
	}

	if (fgets(str, MAXPATHLEN, inpipe) == 0) {
		wrapper_exit("%s wrapper: could not get linker binary path: %s\n",
			StringGetBuffer(data->name), strerror(errno));
	}

	data->bin = StringCreateConcat(str, -1
		, "/", 1
		, StringGetBuffer(data->name), StringGetLength(data->name)
	, NULL);

	pclose(inpipe);
}

static inline void abspath(char * const path, int * const plen)
{
	char *pos;
	char *current;
	char *end;
	int drop;
	int last = *plen;

	/* drop double "//" */
	current = path;
	while((pos = strstr(current, "//")) != NULL) {
		for(end = ++pos; *end == '/' && *end != '\0'; ++end);
		drop = end - pos;
		memmove(pos, end, *plen - (end - path) + 1);
		*plen -= drop;
		current = pos;
	}

	/* drop "/." */
	current = path;
	while((pos = strstr(current, "/.")) != NULL) {
		end = pos + 2;
		if (*end != '\0' && *end != '/') {
			/* is not pure "/." */
			current = end;
			continue;
		}
		if (pos == path && *end == '\0') {
			/* keep leading slash, if any */
			++pos;
		}
		drop = end - pos;
		memmove(pos, end, *plen - (end - path) + 1);
		*plen -= drop;
		current = pos;
	}

	/* drop "/previous/.." */
	current = path;
	while((pos = strstr(current, "/..")) != NULL) {
		end = pos + 3;
		if (*end != '\0' && *end != '/') {
			current = end;
			continue;
		}
		current = pos;
		/* find previous "/" */
		while(--current >= path && *current != '/');
		if (strncmp(current+1, "../", 3) == 0) {
			/* keep leading "../", or it would have been dropped */
			current = end;
			continue;
		}
		if (current < path) {
			/* there is no leading slash */
			++current;
			if (pos > current) {
				/* this is not leading "/.." */
				if (*end == '\0') {
					/* keep at least one ".", take the one at the end */
					--end;
				} else {
					/* do not add a leading slash */
					++end;
				}
			} else {
				/* keep leading slash */
				++current;
			}
		}
		if (current >= end) {
			/* nothing to drop */
			current = end;
			continue;
		}
		drop = end - current;
		memmove(current, end, *plen - (end - path) + 1);
		*plen -= drop;
	}

	if (strncmp(path, "./", 2) == 0 && *plen > 2) {
		/* drop leading "./" if not alone */
		memmove(path, path+2, *plen - 2 + 1);
		*plen -= 2;
	}
	if (*plen > 1 && path[*plen-1] == '/') {
		/* drop trailing "/" if not alone */
		path[--*plen] = '\0';
	}
	return;
}

static inline int filterSysLibpath(LdPluginData* pluginData)
{
	int argc;
	String const *argString;
	char const *argBuffer;
	int argLength;
	char *abspathBuffer;
	int abspathLength;

	for(argc = 1; argc < StringListGetSize(pluginData->in->argList); argc++) {
		argString = StringListGetString(pluginData->in->argList, argc);
		argBuffer = StringGetBuffer(argString);
		argLength = StringGetLength(argString);

		if (strncmp(argBuffer, "-L", 2) == 0) {
			argBuffer += 2;
			argLength -= 2;
			
			if (*argBuffer == 0) {
				if (argc+1 == StringListGetSize(pluginData->in->argList)) {
					/* no more arguments */
					continue;
				}
				argString = StringListGetString(pluginData->in->argList, ++argc);
				argBuffer = StringGetBuffer(argString);
				argLength = StringGetLength(argString);
			}

			/* need a dup to be changed by abspathpath() */
			abspathBuffer = malloc(argLength+1);
			if (abspathBuffer == NULL) {
				break;
			}
			memcpy(abspathBuffer, argBuffer, argLength+1);
			abspathLength = argLength;

			abspath(abspathBuffer, &abspathLength);

			/* add to user libpath list */
			if (StringListAppendConcat(pluginData->in->userLibpath, argBuffer, argLength, NULL) < 0)
				break;

			/* keep user libpath on commandline */
			if (StringListAppendConcat(pluginData->out->argList, "-L", 2, argBuffer, argLength, NULL) < 0)
				break;

			/* end -L handling */
			continue;
		}

		/* keep other arguments on commandline */
		if (StringListAppendString(pluginData->out->argList, argString) < 0)
			break;
	}

	if (argc < StringListGetSize(pluginData->in->argList)) {
		return -1;
	}

	return 0;
}

typedef enum _AddLibpathType {
	AddLibpath,
	TestAndAddLibpath,
	TestLibpath
} AddLibpathType;

static inline int add_libpath(LdWrapperData* data, StringList* list, AddLibpathType type,
		char const *diagnostics,
		char const *path, int len,
		...)
{
	va_list args;
	int rv = 1;
	String* tmp;
	struct stat statbuf;

	va_start(args, len);
	tmp = StringCreateVaConcat(path, len, args);
	va_end(args);
	if (tmp == NULL) {
		wrapper_exit("%s wrapper: %s: %s\n",
			StringGetBuffer(data->name), diagnostics, strerror(errno));
	}

	switch(type) {
	case TestAndAddLibpath:
	case TestLibpath:
		if (stat(StringGetBuffer(tmp), &statbuf) != 0 || !(statbuf.st_mode & S_IFDIR)) {
			rv = 0;
		}
		break;
	default:
		break;
	}
	switch(type) {
	case AddLibpath:
	case TestAndAddLibpath:
		if (rv && StringListAppendString(list, tmp) < 0) {
			wrapper_exit("%s wrapper: %s: %s\n",
				StringGetBuffer(data->name), diagnostics, strerror(errno));
		}
		break;
	default:
		break;
	}
	if (rv == 0) {
		dprintf(stderr, "%s wrapper: %s: '%s': skipped.\n",
			StringGetBuffer(data->name), diagnostics, StringGetBuffer(tmp));
	} else {
		dprintf(stderr, "%s wrapper: %s: '%s': done.\n",
			StringGetBuffer(data->name), diagnostics, StringGetBuffer(tmp));
	}
	tmp = StringDestroy(tmp);
	return rv;
}

/* Append target's toolchain to runpath.
 * This needs to be done when whe do
 * cross-prefix or cross-triplet.
 */
static inline void add_target_toolchain_runpath(LdWrapperData* data)
{
	if (data->pluginIn.isCrossTriplet
	 || data->pluginIn.isCrossEprefix
	) {
		add_libpath(data, data->pluginIn.sysRunpath, TestAndAddLibpath,
			"append target toolchain to runpath",
			StringGetBuffer(data->pluginIn.target.eprefix),
			StringGetLength(data->pluginIn.target.eprefix),
			"/usr/", strlen("/usr/"),
			StringGetBuffer(data->pluginIn.target.triplet),
			StringGetLength(data->pluginIn.target.triplet),
			"/lib/gcc", strlen("/lib/gcc"),
		NULL);
		add_libpath(data, data->pluginIn.sysRunpath, AddLibpath,
			"append target toolchain to runpath",
			StringGetBuffer(data->pluginIn.target.eprefix),
			StringGetLength(data->pluginIn.target.eprefix),
			"/usr/", strlen("/usr/"),
			StringGetBuffer(data->pluginIn.target.triplet),
			StringGetLength(data->pluginIn.target.triplet),
			"/lib", strlen("/lib"),
		NULL);
	}
}

static inline void add_target_toolchain_libpath(LdWrapperData* data)
{
}

/* Append host's cross-toolchain to libpath.
 * This needs to be done when we do
 * cross-triplet only.
 */
static inline void add_cross_toolchain_runpath(LdWrapperData* data)
{
}

static inline void add_cross_toolchain_libpath(LdWrapperData* data)
{
	if (data->pluginIn.isCrossTriplet) {
		add_libpath(data, data->pluginIn.sysLibpath, AddLibpath,
			"append cross toolchain to libpath",
			StringGetBuffer(data->pluginIn.host.eprefix),
			StringGetLength(data->pluginIn.host.eprefix),
			"/usr/", strlen("/usr/"),
			StringGetBuffer(data->pluginIn.host.triplet),
			StringGetLength(data->pluginIn.host.triplet),
			"/", strlen("/"),
			StringGetBuffer(data->pluginIn.target.triplet),
			StringGetLength(data->pluginIn.target.triplet),
			"/lib/gcc", strlen("/lib/gcc"),
		NULL);
		add_libpath(data, data->pluginIn.sysLibpath, AddLibpath,
			"append cross toolchain to libpath",
			StringGetBuffer(data->pluginIn.host.eprefix),
			StringGetLength(data->pluginIn.host.eprefix),
			"/usr/", strlen("/usr/"),
			StringGetBuffer(data->pluginIn.host.triplet),
			StringGetLength(data->pluginIn.host.triplet),
			"/", strlen("/"),
			StringGetBuffer(data->pluginIn.target.triplet),
			StringGetLength(data->pluginIn.target.triplet),
			"/lib", strlen("/lib"),
		NULL);
	}
}

/* Append host's toolchain.
 * This only needs to be done when we do a native triplet build.
 *
 * Add to libpath always.
 *
 * Add to runpath only if this is a native prefix build,
 * or we are not using ROOT, as the target binary should be able
 * to run even if there are dependencies missing in target eprefix,
 * as during bootstrap.
 */
static inline void add_host_toolchain_runpath(LdWrapperData* data)
{
	if (data->pluginIn.isCrossTriplet) {
		return;
	}

	if (! data->pluginIn.haveRoot
	 || ! data->pluginIn.isCrossEprefix
	) {
		add_libpath(data, data->pluginIn.sysRunpath, AddLibpath,
			"append host toolchain to runpath",
			StringGetBuffer(data->pluginIn.host.eprefix),
			StringGetLength(data->pluginIn.host.eprefix),
			"/usr/", strlen("/usr/"),
			StringGetBuffer(data->pluginIn.host.triplet),
			StringGetLength(data->pluginIn.host.triplet),
			"/lib/gcc", strlen("/lib/gcc"),
		NULL);
		add_libpath(data, data->pluginIn.sysRunpath, AddLibpath,
			"append host toolchain to runpath",
			StringGetBuffer(data->pluginIn.host.eprefix),
			StringGetLength(data->pluginIn.host.eprefix),
			"/usr/", strlen("/usr/"),
			StringGetBuffer(data->pluginIn.host.triplet),
			StringGetLength(data->pluginIn.host.triplet),
			"/lib", strlen("/lib"),
		NULL);
	}
}

static inline void add_host_toolchain_libpath(LdWrapperData* data)
{
	if (data->pluginIn.isCrossTriplet) {
		return;
	}

	add_libpath(data, data->pluginIn.sysLibpath, TestAndAddLibpath,
		"append host toolchain to libpath",
		StringGetBuffer(data->pluginIn.host.eprefix),
		StringGetLength(data->pluginIn.host.eprefix),
		"/usr/", strlen("/usr/"),
		StringGetBuffer(data->pluginIn.host.triplet),
		StringGetLength(data->pluginIn.host.triplet),
		"/lib/gcc", strlen("/lib/gcc"),
	NULL);
	add_libpath(data, data->pluginIn.sysLibpath, AddLibpath,
		"append host toolchain to libpath",
		StringGetBuffer(data->pluginIn.host.eprefix),
		StringGetLength(data->pluginIn.host.eprefix),
		"/usr/", strlen("/usr/"),
		StringGetBuffer(data->pluginIn.host.triplet),
		StringGetLength(data->pluginIn.host.triplet),
		"/lib", strlen("/lib"),
	NULL);
}

/* Append target system to runpath.
 *
 * As they are not read from any target config file, we can check them
 * for existance, as ${ROOT}${EPREFIX} really should be accessible
 * from this cross-compiling host.
 *
 * This only needs to be done if we do
 * cross-eprefix or use ROOT.
 */
static inline void add_target_system(LdWrapperData* data)
{
	struct libdir {
		char const *path; int len;
	};
	struct libdir const libdirs[] = {
		{ "/usr/lib",   strlen("/usr/lib"), },
		{ "/lib",       strlen("/lib"), },
		{ NULL, -1 },
	};
	struct libdir const * l = libdirs;

	if (data->pluginIn.isCrossEprefix
	 || data->pluginIn.haveRoot /* cross-triplet must use ROOT */
	) {
		while(l->path != NULL) {
			if (add_libpath(data, data->pluginIn.sysLibpath, TestAndAddLibpath,
					"append target system to libpath",
					StringGetBuffer(data->pluginIn.root),
					StringGetLength(data->pluginIn.root),
					StringGetBuffer(data->pluginIn.target.eprefix),
					StringGetLength(data->pluginIn.target.eprefix),
					l->path, l->len,
				NULL)
			) {
				add_libpath(data, data->pluginIn.sysRunpath, AddLibpath,
					"append target system to runpath",
					StringGetBuffer(data->pluginIn.target.eprefix),
					StringGetLength(data->pluginIn.target.eprefix),
					l->path, l->len,
				NULL);
			}
			l++;
		}
	}
}

/* Append host system.
 *
 * This needs to be done when we do
 *              |cross-triplet | cross-eprefix | use ROOT |
 * -------------+--------------+---------------+----------+
 * cross-triplet|     ---      |      ---      |   ---    |
 * cross-eprefix|     ---      |      l r      |   l      |
 * use ROOT     |     ---      |      l        |   l r    |
 * -------------+--------------+---------------+----------+
 * eprefix, or cross-
 * *) this is a native build,
 * *) this is cross-prefix or we have ROOT
 *
 * additionally, append the system libdirs from this host to runpath when
 *
 * *) this is a cross eprefix build and we do not have ROOT,
 *    because it is likely that the created binaries are executed from the
 *    new prefix, while still can use dependent libs from the old prefix.
 */
static inline void add_host_system(LdWrapperData* data)
{
	struct libdir {
		char const *path; int len; int exists;
	};
	struct libdir libdirs[] = {
		{ "/usr/lib",   strlen("/usr/lib"), 0, },
		{ "/lib",       strlen("/lib"),     0, },
		{ NULL, -1, 0, },
	};
	struct libdir * l = libdirs;

	if (data->pluginIn.isCrossTriplet) {
		/* native builds only */
		return;
	}

	while(l->path != NULL) {
		if (add_libpath(data, data->pluginIn.sysLibpath, TestAndAddLibpath,
				"append host system to libpath",
				StringGetBuffer(data->pluginIn.host.eprefix),
				StringGetLength(data->pluginIn.host.eprefix),
				l->path, l->len,
			NULL)
		 && (data->pluginIn.isCrossEprefix
		  || ! data->pluginIn.haveRoot
		 )
		) {
			l->exists = 1;
		}
		l++;
	}

	/* Add to runpath in reverse order: This is to replace existing shared
	 * libraries without SONAME on AIX with ones that define a SONAME.
	 * The old one can be found as lib/libz.so fex, while linking
	 * against usr/lib/libz.so will record libz.so.1 into the binaries.
	 */
	while(--l >= libdirs) {
		if (l->exists) {
			/* add to runpath only when cross-prefix without ROOT */
			add_libpath(data, data->pluginIn.sysRunpath, AddLibpath,
				"append host system to runpath",
				StringGetBuffer(data->pluginIn.host.eprefix),
				StringGetLength(data->pluginIn.host.eprefix),
				l->path, l->len,
			NULL);
		}
	}
}

static inline void callPlugin(LdWrapperData* data, LdPluginFct plugins)
{
	LdPluginData pluginData = {0};
	LdPluginOut pluginOut = {0};

	pluginData.in = &data->pluginIn;
	pluginData.out = &pluginOut;
	pluginData.plugin = *plugins;

	/* keep argv[0] */
	pluginData.out->argList = StringListCreate(pluginData.in->argList, 0, 1);
	if (pluginData.out->argList == NULL) {
		wrapper_exit("%s wrapper: %s\n",
			StringGetBuffer(data->name), strerror(errno));
	}

	if ((*plugins)(&pluginData) < 0) {
		if (pluginData.out->diagnostics == NULL) {
			wrapper_exit("%s wrapper: %s: %s\n",
				StringGetBuffer(data->name), pluginData.out->diagnostics, strerror(errno));
		} else {
			wrapper_exit("%s wrapper could not run plugin: %s\n",
				StringGetBuffer(data->name), strerror(errno));
		}
	}
	if (pluginOut.argList != NULL) {
		StringListDestroy(data->pluginIn.argList);
		data->pluginIn.argList = pluginOut.argList;
	}
}

typedef struct _KnownPlugin {
	int namelen;
	char const *name;
	LdPluginFct plugin;
} KnownPlugin;

static inline int compareKnownPluginName(void const *v1, void const *v2)
{
	KnownPlugin const* p1 = (KnownPlugin const*)v1;
	KnownPlugin const* p2 = (KnownPlugin const*)v2;
	int rv;
	rv = p1->namelen - p2->namelen;
	if (rv) return rv;
	return strncmp(p1->name, p2->name, p1->namelen);
}

/* call the plugins from comma-separated list of plugin-names */
static inline void callPlugins(LdWrapperData* data, char const* plugins)
{
	char const *end;
	static KnownPlugin const knownPlugins[] = {
		/* keep sorted on namelen,name */
		{ 3, "aix", aixplugin },
		{ 3, "gnu", gnuplugin },
		{ 4, "hpux", hpuxplugin },
		{ 6, "darwin", darwinplugin },
		{ 7, "solaris", solarisplugin },
	};
	KnownPlugin search;
	KnownPlugin *found;

	if (plugins == NULL) {
		return;
	}

	while(plugins != NULL && *plugins != '\0') {
		end = strchr(plugins, ',');
		if (end == NULL) {
			end = plugins + strlen(plugins);
		}
		search.name = plugins;
		search.namelen = end - plugins;
		found = bsearch(&search, knownPlugins,
				sizeof(knownPlugins) / sizeof(knownPlugins[0]),
				sizeof(knownPlugins[0]),
				compareKnownPluginName);
		if (found != NULL) {
			callPlugin(data, found->plugin);
		}
		while (*end == ',') end++;
		plugins = end;
	}

	return;
}

int main(int argc, char *argv[])
{
	String *tmpString = NULL;
	LdWrapperData data;
	int len;
	char **newargv = argv;
	char const *found;
	char const *tmp;

	memset(&data, 0, sizeof(data));

	dprintf(stderr, "ld-wrapper called as: %s\n", argv[0]);

	/* What should we find? */
	tmp = basename(argv[0]);
	found = strrchr(tmp, '-');
	if (found != NULL) {
		found++;
	} else {
		found = tmp;
	}
	data.name = StringCreateConcat(found, -1, NULL);
	if (data.name == NULL) {
		wrapper_exit("%s wrapper: %s\n", argv[0], strerror(errno));
	}

	found = getenv("PATH");
	if (found) {
		data.envpath = StringListFromSeparated(found, -1, ":", 1);
		if (data.envpath == NULL) {
			wrapper_exit("%s wrapper: %s\n",
				StringGetBuffer(data.name), strerror(errno));
		}
	}

	/* builtins */
	data.pluginIn.host.triplet = StringCreateConcat(CHOST, strlen(CHOST), NULL);
	if (data.pluginIn.host.triplet == NULL) {
		wrapper_exit("%s wrapper: %s\n",
			StringGetBuffer(data.name), strerror(errno));
	}

	data.pluginIn.host.eprefix = StringCreateConcat(
		GENTOO_PORTAGE_EPREFIX, strlen(GENTOO_PORTAGE_EPREFIX),
	NULL);
	if (data.pluginIn.host.eprefix == NULL) {
		wrapper_exit("%s wrapper: %s\n",
			StringGetBuffer(data.name), strerror(errno));
	}

	if (stat(argv[0], &data.arg0stat) != 0) {
		tmpString = StringCreateConcat(
			StringGetBuffer(data.pluginIn.host.eprefix),
			StringGetLength(data.pluginIn.host.eprefix),
			"/usr/bin/", strlen("/usr/bin/"),
			StringGetBuffer(data.name), StringGetLength(data.name),
		NULL);
		if (tmpString == NULL) {
			wrapper_exit("%s wrapper: %s\n",
				StringGetBuffer(data.name), strerror(errno));
		}
		if (stat(StringGetBuffer(tmpString), &data.arg0stat) != 0) {
			wrapper_exit("%s wrapper: \"%s\": %s\n",
				StringGetBuffer(data.name),
				StringGetBuffer(tmpString),
				strerror(errno));
		}
	}

	/* environments with fallbacks to builtins */
	found = getenv("ROOT");
	if (!found) {
		found = "/";
	}
	len = strlen(found);
	while (len > 0 && found[len-1] == '/')
		len--;
	data.pluginIn.root = StringCreateConcat(found, len, NULL);
	if (data.pluginIn.root == NULL) {
		wrapper_exit("%s wrapper: %s\n",
			StringGetBuffer(data.name), strerror(errno));
	}
	data.pluginIn.haveRoot = StringGetLength(data.pluginIn.root) > 0 ? 1 : 0;

	found = getenv("EPREFIX");
	if (found && !StringIsEqual(data.pluginIn.host.eprefix, 0, found, -1)) {
		data.pluginIn.target.eprefix = StringCreateConcat(found, -1, NULL);
		data.pluginIn.isCrossEprefix = 1;
	} else {
		data.pluginIn.target.eprefix = StringDup(data.pluginIn.host.eprefix);
		data.pluginIn.isCrossEprefix = 0;
	}
	if (data.pluginIn.target.eprefix == NULL) {
		wrapper_exit("%s wrapper: %s\n",
			StringGetBuffer(data.name), strerror(errno));
	}

	found = getenv("BINUTILS_CONFIG_LDTARGET");
	if (found == NULL) {
		found = CTARGET();
	}
	data.pluginIn.target.triplet = StringCreateConcat(found, -1, NULL);
	if (data.pluginIn.target.triplet == NULL) {
		wrapper_exit("%s wrapper: %s\n",
			StringGetBuffer(data.name), strerror(errno));
	}

	dprintf(stderr, "%s wrapper: chost '%s'\n",
		StringGetBuffer(data.name), StringGetBuffer(data.pluginIn.host.triplet));
	dprintf(stderr, "%s wrapper: ctarget '%s'\n",
		StringGetBuffer(data.name), StringGetBuffer(data.pluginIn.target.triplet));
	dprintf(stderr, "%s wrapper: host eprefix '%s'\n",
		StringGetBuffer(data.name), StringGetBuffer(data.pluginIn.host.eprefix));
	dprintf(stderr, "%s wrapper: target eprefix '%s'\n",
		StringGetBuffer(data.name), StringGetBuffer(data.pluginIn.target.eprefix));

	data.pluginIn.isCrossTriplet = StringIsEqualString(
		data.pluginIn.host.triplet, data.pluginIn.target.triplet
	) ? 0 : 1;

	find_wrapper_binutils(&data);

	if (data.envpath) {
		data.envpath = StringListDestroy(data.envpath);
	}

	data.pluginIn.argList = StringListFromArgv(argc, argv);
	if (data.pluginIn.argList == NULL) {
		wrapper_exit("%s wrapper: %s\n",
			StringGetBuffer(data.name), strerror(errno));
	}

	data.pluginIn.userLibpath = StringListCreate(NULL, 0, 0);
	if (data.pluginIn.userLibpath == NULL) {
		wrapper_exit("cannot create user libpath list: %s\n", strerror(errno));
	}

	data.pluginIn.sysLibpath = StringListCreate(NULL, 0, 0);
	if (data.pluginIn.sysLibpath == NULL) {
		wrapper_exit("cannot create sys libpath list: %s\n", strerror(errno));
	}

	data.pluginIn.sysRunpath = StringListCreate(NULL, 0, 0);
	if (data.pluginIn.sysRunpath == NULL) {
		wrapper_exit("cannot create sys runpath list: %s\n", strerror(errno));
	}

	add_target_toolchain_libpath(&data);
	add_cross_toolchain_libpath(&data);
	add_host_toolchain_libpath(&data);

	add_target_toolchain_runpath(&data);
	add_cross_toolchain_runpath(&data);

	add_target_system(&data);

	add_host_toolchain_runpath(&data);
	add_host_system(&data);

	/* filter out sys libpath's passed with "-L" */
	callPlugin(&data, filterSysLibpath);

	found = getenv("BINUTILS_CONFIG_LDPLUGINS");
	if (found == NULL) {
		found = LDPLUGINS();
	}
	/* call the target specific plugin */
	callPlugins(&data, found);

	newargv = StringListToArgv(data.pluginIn.argList);
	if (newargv == NULL) {
		wrapper_exit("cannot create argument array: %s\n", strerror(errno));
	}

	if (DEBUG() || getenv("BINUTILS_CONFIG_VERBOSE") != NULL) {
		int i;
		fprintf(stderr, "'%s'", StringGetBuffer(data.bin));
		for (i = 0; newargv[i] != NULL; i++) {
			fprintf(stderr, " \\\n    '%s'", newargv[i]);
		}
		fprintf(stderr, "\n");
	}

	/* Ok, lets do it one more time ... */
	if (execv(StringGetBuffer(data.bin), newargv) < 0)
		wrapper_exit("Could not run/locate \"%s/%s\" (%s)\n",
			StringGetBuffer(data.pluginIn.target.triplet),
			StringGetBuffer(data.name),
			StringGetBuffer(data.bin));

	return 0;
}
