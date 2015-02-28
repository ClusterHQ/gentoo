/*
 * Copyright 2007-2012 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * Author: Michael Haubenwallner <haubi@gentoo.org>
 */

#include <config.h>

#include "hpuxplugin.h"

#include <stdlib.h>
#include <string.h>

#if defined(__cplusplus)
extern "C" {
#else
typedef enum { false = 0, true = 1 } bool;
#endif

typedef enum { EnvRpath_No = 0, EnvRpath_First = 1, EnvRpath_Second = 2 } EnvRpathFlag;
typedef enum { UseRpath_Concat = 0, UseRpath_First = 1, UseRpath_Last = 2 } UseRpathFlag;
typedef enum { LinkMode_ELF = 0, LinkMode_SOM = 1, LinkMode_Compat = 2 } LinkModeType;

/* HPUX-ld:
 * ELF: When there is no explicit runpath on the linker commandline (+b runpath),
 *      then all library paths (-L) are recorded as runpath
 * SOM: Runpath used to be stored on explicit flag (+b runpath) only. 
 *      When there is "+b :", then library paths (-L) are recorded as runpath.
 *      We assume "+b :" is set at least, to get our paths searched always.
 */
int hpuxplugin(LdPluginData *data)
{
	int argc = 0;
	int err;
	int index, count;
	bool isIA64;
	bool is64bit;

	/* ELF settings */
	bool needLibpathAsRunpath = true;
	bool needAutoRunpath = false;
	UseRpathFlag useRpathFlag = UseRpath_Last;
	bool needCDPflag = false; /* need +cdp linker flag to drop DESTDIR */

	EnvRpathFlag envRpathFlag = EnvRpath_No;	/* +s */
	StringList *tmpArgList = NULL;
	StringList *userLibpathList = NULL;
	StringList *runpathList = NULL;
	StringList *defaultRunpathList = NULL;
	StringList *sysRunpathList = NULL;
	StringList *autoRunpathList = NULL;
	String *newString = NULL;
	String const *argString;
	char const *argBuffer;
	int argBufferLength;
	char const *portageD = NULL;
	int portageDlength = 0;
	bool isShared = false;

	do {	/* dummy loop */
		err = -1;

		tmpArgList = StringListCreate(NULL, 0, 0);
		if (tmpArgList == NULL)
			break;

		userLibpathList = StringListCreate(NULL, 0, 0);
		if (userLibpathList == NULL)
			break;

		runpathList = StringListCreate(NULL, 0, 0);
		if (runpathList == NULL)
			break;

		defaultRunpathList = StringListCreate(NULL, 0, 0);
		if (defaultRunpathList == NULL)
			break;

		sysRunpathList = StringListCreate(NULL, 0, 0);
		if (sysRunpathList == NULL)
			break;

		autoRunpathList = StringListCreate(NULL, 0, 0);
		if (autoRunpathList == NULL)
			break;

#define STRnLEN(x) (x), strlen((x))
		argBuffer = StringGetBuffer(data->in->host.triplet);
		if (strncmp(argBuffer, "ia64", strlen("ia64")) == 0) {
			isIA64 = true;
			if (argBuffer[strlen("ia64")] == 'w') {
				/* ia64w: ELF, 64bit */
				is64bit = true;
				if (0
				 /* added by gcc always */
				 || StringListAppendConcat(sysRunpathList,  STRnLEN("/usr/ccs/lib/hpux64"), NULL) < 0
				 || StringListAppendConcat(sysRunpathList,  STRnLEN("/lib/hpux64"        ), NULL) < 0
				 || StringListAppendConcat(sysRunpathList,  STRnLEN("/usr/lib/hpux64"    ), NULL) < 0
				 || StringListAppendConcat(sysRunpathList,  STRnLEN("/usr/ccs/lib"       ), NULL) < 0
				 /* added by ld upon "+b :", but done by gcc already
				 || StringListAppendConcat(autoRunpathList, STRnLEN("/usr/lib/hpux64"    ), NULL) < 0
				 */
				)
					break;
			} else {
				is64bit = false;
				if (0
				 /* added by gcc always */
				 || StringListAppendConcat(sysRunpathList,  STRnLEN("/usr/ccs/lib"   ), NULL) < 0
				 /* added by ld upon "+b :" */
				 || StringListAppendConcat(autoRunpathList, STRnLEN("/usr/lib/hpux32"), NULL) < 0
				)
					break;
			}
		} else
		if (strncmp(argBuffer, "hppa64", strlen("hppa64")) == 0) {
			/* hppa64: ELF, 64bit */
			isIA64 = false;
			is64bit = true;
			if (0
			 /* added by gcc always */
			 || StringListAppendConcat(sysRunpathList,  STRnLEN("/usr/ccs/lib/pa20_64"      ), NULL) < 0
			 || StringListAppendConcat(sysRunpathList,  STRnLEN("/opt/langtools/lib/pa20_64"), NULL) < 0
			 || StringListAppendConcat(sysRunpathList,  STRnLEN("/lib/pa20_64"              ), NULL) < 0
			 || StringListAppendConcat(sysRunpathList,  STRnLEN("/usr/lib/pa20_64"          ), NULL) < 0
			 /* added by ld upon "+b :", but done by gcc already
			 || StringListAppendConcat(autoRunpathList, STRnLEN("/usr/lib/pa20_64"          ), NULL) < 0
			 || StringListAppendConcat(autoRunpathList, STRnLEN("/usr/ccs/lib/pa20_64"      ), NULL) < 0
			 */
			)
				break;
		} else {
			/* hppa: SOM, 32bit */
			isIA64 = false;
			is64bit = false;
			if (0
			 /* added by gcc always */
			 || StringListAppendConcat(sysRunpathList, STRnLEN("/usr/ccs/lib"      ), NULL) < 0
			 || StringListAppendConcat(sysRunpathList, STRnLEN("/opt/langtools/lib"), NULL) < 0
			 /* added by ld upon "+b :" */
			)
				break;
		}

		if (!isIA64 && is64bit) {
			/* hppa64 only */
			for(argc = 1; argc < StringListGetSize(data->in->argList); argc++) {
				argString = StringListGetString(data->in->argList, argc);
				argBuffer = StringGetBuffer(argString);
				if (strcmp(argBuffer, "+concatrpath") == 0) {
					useRpathFlag = UseRpath_Concat;
				} else 
				if (strcmp(argBuffer, "+noconcatrpath") == 0) {
					useRpathFlag = UseRpath_Last;
				}
			}
		}

		if (!isIA64 && !is64bit) {
			/* hppa only */
			useRpathFlag = UseRpath_First;
			/* help elibtoolize with old libtool */
			portageD = getenv("D");
			if (portageD != NULL) {
				portageDlength = strlen(portageD);
				needCDPflag = true;
			}
		}

		for(argc = 1; argc < StringListGetSize(data->in->argList); argc++) {
			argString = StringListGetString(data->in->argList, argc);
			argBuffer = StringGetBuffer(argString);
			argBufferLength = StringGetLength(argString);

			if (strcmp(argBuffer, "-b") == 0) {
				isShared = true;
				/* add to commandline */
			} else
			if (strcmp(argBuffer, "+s") == 0) {
				if (StringListGetSize(runpathList) + StringListGetSize(autoRunpathList))
					envRpathFlag = EnvRpath_Second;
				else
					envRpathFlag = EnvRpath_First;
				continue;
			} else
			if (strcmp(argBuffer, "+nodefaultrpath") == 0) {
				needLibpathAsRunpath = false;
				continue;
			} else
			if (strcmp(argBuffer, "+defaultrpath") == 0) {
				/* SOM: Unrecognized argument */
				if (isIA64 || is64bit) {
					needLibpathAsRunpath = true;
					continue;
				} /* else append to args */
			} else
			if (strncmp(argBuffer, "+b", 2) == 0) {
				/* collect runpath from "+b runpath1:runpathN" */
				char const *curr, *next;

				argBuffer += 2;
				argBufferLength -= 2;

				if (*argBuffer == 0 && argc < StringListGetSize(data->in->argList)) {
					argc++;
					argString = StringListGetString(data->in->argList, argc);
					argBuffer = StringGetBuffer(argString);
					argBufferLength = StringGetLength(argString);
				}

				needLibpathAsRunpath = false;

				if (useRpathFlag != UseRpath_Concat) {
					if (StringListGetSize(runpathList) + StringListGetSize(autoRunpathList)) {
						if (useRpathFlag == UseRpath_First) {
							continue;
						}
						StringListClear(runpathList);
						StringListClear(autoRunpathList);
					}

					if (argBufferLength == 1 && argBuffer[0] == ':') {
						/* "+b:" collects all "-L" paths and LPATH envvar */
						needLibpathAsRunpath = true;
						needAutoRunpath = true;
						continue;
					}
				}

				for(curr = next = argBuffer; *next != '\0'; curr = next+1) {
					for(next = curr; *next != '\0' && *next != ':'; next++);

					if (next - curr <= 1) {
						/* skip empty path */
						continue;
					}

					if (StringListContains(data->in->sysLibpath, curr, next - curr)) {
						/* sys runpath will be added later */
						continue;
					}

					if (StringListContains(runpathList, curr, next - curr)) {
						/* already recorded user runpath */
						continue;
					}

					/* record this path into libpath list */
					if (StringListAppendConcat(runpathList, curr, next - curr, NULL) < 0)
						break;
				}

				/* end "+b" handling */
				continue;
			} else
			if (strncmp(argBuffer, "-L", 2) == 0) {
				/* drop -L arguments from commandline,
				 * we need to pass them before any libs.
				 * The path list already is collected in userLibpath.
				 */
				continue;
			} else
			if (strncmp(argBuffer, "-R", 2) == 0) {
				/* extension:
				 * collect additional default runpath from "-R runpath"
				 */

				argBuffer += 2;
				argBufferLength -= 2;

				if (*argBuffer == 0 && argc < StringListGetSize(data->in->argList)) {
					argc++;
					argString = StringListGetString(data->in->argList, argc);
					argBuffer = StringGetBuffer(argString);
					argBufferLength = StringGetLength(argString);
				}
				if (StringListContains(data->in->sysLibpath, argBuffer, argBufferLength))
					continue;

				if (StringListAppendConcat(defaultRunpathList, argBuffer, argBufferLength, NULL) < 0)
					break;

				continue;
			} else
			if (strncmp(argBuffer, "+cdp", strlen("+cdp")) == 0) {
				needCDPflag = false;
				/* append this flag */
			}

			/* keep other arguments on commandline */
			if (StringListAppendString(tmpArgList, argString) < 0)
				break;
		}
		if (argc < StringListGetSize(data->in->argList)) {
			/* error during argument parsing */
			break;
		}

		/* uniq userLibpath, filter hpux system runpath from userLibpath */
		count = StringListGetSize(data->in->userLibpath);
		for(index = 0; index < count; ++index) {
			String const* pathString;
			char const* pathBuffer;
			int pathLength;
			pathString = StringListGetString(data->in->userLibpath, index);
			pathBuffer = StringGetBuffer(pathString);
			pathLength = StringGetLength(pathString);
			if (StringListContains(userLibpathList, pathBuffer, pathLength)
			 || StringListContains(sysRunpathList, pathBuffer, pathLength)
			 || StringListContains(autoRunpathList, pathBuffer, pathLength)
			)
				continue;
			if (StringListAppendConcat(userLibpathList, pathBuffer, pathLength, NULL) < 0)
				break;
		}
		if (index < count)
			break;

		/* Work around occasional segmentation faults and illegal instructions
		 * caused by deferred symbol resolution (maybe NFS related), both on
		 * ia64-hpux and hppa-hpux.
		 * HP-UX ld manpage suggests to use "-B nonfatal" and "-B verbose" 
		 * in combination with "-B immediate".
		 *
		 * The last one of multiple incompatible "-B" arguments is used.
		 */
		if (!isShared
		 && (StringListAppendConcat(data->out->argList, STRnLEN("-B"), NULL) < 0
		  || StringListAppendConcat(data->out->argList, STRnLEN("immediate"), NULL) < 0
		  || StringListAppendConcat(data->out->argList, STRnLEN("-B"), NULL) < 0
		  || StringListAppendConcat(data->out->argList, STRnLEN("nonfatal"), NULL) < 0
		  || StringListAppendConcat(data->out->argList, STRnLEN("-B"), NULL) < 0
		  || StringListAppendConcat(data->out->argList, STRnLEN("verbose"), NULL) < 0
		 )
		) break;

		/*
		 * first, put libpath list (-L) on the commandline
		 */
		if (StringListAppendListModify(data->out->argList, userLibpathList, 0, -1, "-L", 2, NULL, 0) < 0)
			break;

		/* also put sys libpath list as libpath (-L) on commandline */
		if (StringListAppendListModify(data->out->argList, data->in->sysLibpath, 0, -1, "-L", 2, NULL, 0) < 0)
			break;

		/* finally, put the host system runpath as libpath (-L) on commandline */
		if (StringListAppendListModify(data->out->argList, sysRunpathList, 0, -1, "-L", 2, NULL, 0) < 0)
			break;

		/* do we need to use env-runpath first? */
		if (envRpathFlag == EnvRpath_First
		 && StringListAppendConcat(data->out->argList, "+s", 2, NULL) < 0
		) break;

		/*
		 * now put runpath list (from -R, +b) on the commandline
		 */

		/* append "+b" to commandline */
		if (StringListAppendConcat(data->out->argList, "+b", 2, NULL) < 0)
			break;

		/* if there is no runpath (+b), use libpath as runpath
		 * if not disabled with "+nodefaultrpath"
		 */
		if (StringListGetSize(runpathList) == 0
		 && needLibpathAsRunpath == true
		) {
			if (needCDPflag) {
				count = StringListGetSize(userLibpathList);
				bool found = false;
				for(index = 0; index < count; ++index) {
					String const* pathString;
					char const* pathBuffer;
					int pathLength;
					pathString = StringListGetString(userLibpathList, index);
					pathBuffer = StringGetBuffer(pathString);
					pathLength = StringGetLength(pathString);
					if (strncmp(portageD, pathBuffer, portageDlength) == 0) {
						found = true;
						pathBuffer += portageDlength;
						pathLength -= portageDlength;
						if (StringListContains(runpathList, pathBuffer, pathLength)
						 || StringListContains(defaultRunpathList, pathBuffer, pathLength)
						 || StringListContains(data->in->sysRunpath, pathBuffer, pathLength)
						 || StringListContains(sysRunpathList, pathBuffer, pathLength)
						 || StringListContains(autoRunpathList, pathBuffer, pathLength)
						)
							continue;
					}
					if (StringListAppendConcat(runpathList, pathBuffer, pathLength, NULL) < 0)
						break;
				}
				if (index < count)
					break;
				if (!found)
					needCDPflag = false;
			} else
			if (StringListAppendList(runpathList, userLibpathList, 0, -1) < 0)
				break;
		}

		/* append default runpath list (-R) to runpath list */
		if (StringListAppendList(runpathList, defaultRunpathList, 0, -1) < 0)
			break;

		/* append sys libpath list to runpath list */
		if (StringListAppendList(runpathList, data->in->sysRunpath, 0, -1) < 0)
			break;

		/* append local sys libpath list to runpath list */
		if (StringListAppendList(runpathList, sysRunpathList, 0, -1) < 0)
			break;

		/* append automatic sys libpath list to runpath list */
		if (needAutoRunpath
		 && StringListAppendList(runpathList, autoRunpathList, 0, -1) < 0
		)
			break;

		/* create runpath string: runpath1:runpathN */
		newString = StringListJoin(runpathList, NULL, 0, ":", 1, NULL, 0);
		if (newString == NULL)
			break;

		/* append runpath string to commandline */
		if (StringListAppendString(data->out->argList, newString) < 0)
			break;

		/* do we need to use env-runpath second? */
		if (envRpathFlag == EnvRpath_Second
		 && StringListAppendConcat(data->out->argList, "+s", 2, NULL) < 0
		) break;

		/* do we need the "+cdp ${D}:" flag? */
		if (needCDPflag
		 && (StringListAppendConcat(data->out->argList, STRnLEN("+cdp"), NULL) < 0
		  || StringListAppendConcat(data->out->argList, portageD, portageDlength, ":", 1, NULL) < 0
		))
			break;

		/*
		 * third, put other arguments on commandline
		 */
		if (StringListAppendList(data->out->argList, tmpArgList, 0, -1) < 0)
			break;

		err = 0;
	} while(0);	/* end dummy loop */

	newString = StringDestroy(newString);
	autoRunpathList = StringListDestroy(autoRunpathList);
	sysRunpathList = StringListDestroy(sysRunpathList);
	defaultRunpathList = StringListDestroy(defaultRunpathList);
	runpathList = StringListDestroy(runpathList);
	userLibpathList = StringListDestroy(userLibpathList);
	tmpArgList = StringListDestroy(tmpArgList);

	return err;
}

#if defined(__cplusplus)
}
#endif
