/*
 * Copyright 2007-2012 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * Author: Markus Duft <mduft@gentoo.org>
 */

#include <config.h>

#include "solarisplugin.h"

#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/param.h>

#if defined(__cplusplus)
extern "C" {
#endif

int solarisplugin(LdPluginData* data)
{
	const char _rpath[] = "-rpath";
	const int _rpath_len = strlen(_rpath);
	const char _R[] = "-R";
	const int _R_len = strlen(_R);

	int argc = 0;
	int err;
	StringList *runpathList = NULL;
	StringList *tmpArgList = NULL;
	String const *argString;
	String *newString = NULL;
	char const *argBuffer;
	int argLength;
	char const *rpathArg = NULL;
	int rpathArgLen = 0;
	char str[MAXPATHLEN + 1];

	do {	/* dummy loop */
		err = -1;

		runpathList = StringListCreate(NULL, 0, 0);
		if (runpathList == NULL)
			break;

		tmpArgList = StringListCreate(NULL, 0, 0);
		if (tmpArgList == NULL)
			break;

		err = 0;
		for(argc = 1; !err && argc < StringListGetSize(data->in->argList); argc++) {
			err = -1;

			argString = StringListGetString(data->in->argList, argc);
			argBuffer = StringGetBuffer(argString);
			argLength = StringGetLength(argString);

			if (strncmp(argBuffer, "-soname", 7) == 0) {
				/* solaris native ld on sparc archs understands -h only.
				 * x86 versions understand both -soname and -h, so use -h */
				if(StringListAppendConcat(tmpArgList, "-h", 2, NULL) < 0)
					break;

				err = 0;
				continue;
			}

			rpathArg = NULL;

			if (strncmp(argBuffer, _rpath, _rpath_len) == 0) {
				rpathArg = _rpath;
				rpathArgLen = _rpath_len;
				if (argBuffer[rpathArgLen] == '=') {
					++ rpathArgLen;
				} else
				if (argBuffer[rpathArgLen] != '\0') {
					/* is not "-rpath=" */
					rpathArg = NULL;
				}
			} else
			if (strncmp(argBuffer, _R, _R_len) == 0) {
				rpathArg = _R;
				rpathArgLen = _R_len;
			}
			if (rpathArg != NULL) {
				/* collect -rpath path arguments */
				char const *curr, *next;

				argBuffer += rpathArgLen;
				argLength -= rpathArgLen;

				if (*argBuffer == 0 && argc < StringListGetSize(data->in->argList)) {
					argc++;
					argString = StringListGetString(data->in->argList, argc);
					argBuffer = StringGetBuffer(argString);
					argLength = StringGetLength(argString);
				}

				err = 0;
				for (curr = next = argBuffer; !err && *next != '\0'; curr = next+1) {
					err = -1;

					for (next = curr; *next != '\0' && *next != ':'; next++);

					if (curr == argBuffer && rpathArg == _R) {
						struct stat sbuf;
						int rv;
						const char *path = curr;
						if (*next == ':') {
							/* terminate the string in case of ':' */
							memcpy(str, curr, next - curr);
							str[next - curr] = '\0';
							path = str;
						}
						rv = stat(path, &sbuf);
						/* if argument to "-R" is not a directory, then
						 * it is not a rpath, make sure we push out the
						 * entire argument in that case, and not just
						 * everything up to the first : */
						if (rv != 0 || (sbuf.st_mode & S_IFDIR) == 0) {
							if (StringListAppendConcat(tmpArgList
									, _R, _R_len
									, curr, -1
									, NULL) < 0)
							{
								/* failed to append arg */
								break;
							}
							/* done */
							err = 0;
							break;
						}
					}

					if (next - curr <= 1) {
						/* skip empty path */
						err = 0;
						continue;
					}

					if (StringListContains(data->in->sysLibpath, curr, next - curr)) {
						/* skip default path */
						err = 0;
						continue;
					}

					if (StringListContains(runpathList, curr, next - curr)) {
						/* skip already recorded runpath */
						err = 0;
						continue;
					}

					/* record this path into runpath list */
					if (StringListAppendConcat(runpathList, curr, next - curr, NULL) < 0)
						break;

					err = 0;
				}
				if (err)
					break;

				/* end "-rpath" handling */
				continue;
			}

			if (strncmp(argBuffer, "-L", 2) == 0) {
				/* drop -L arguments, as they are in userLibpath list already,
				 * which is added below before sysLibpath list. */
				err = 0;
				continue;
			}

			/* keep other arguments on commandline */
			if (StringListAppendString(tmpArgList, argString) < 0)
				break;

			err = 0;
		}

		if (argc < StringListGetSize(data->in->argList)) {
			/* error during argument parsing */
			break;
		}

		/* append user libpath's with "-L" */
		if (StringListAppendListModify(data->out->argList, data->in->userLibpath, 0, -1, "-L", 2, NULL, 0) < 0)
			break;

		/* append sys libpath's with "-L" */
		if (StringListAppendListModify(data->out->argList, data->in->sysLibpath, 0, -1, "-L", 2, NULL, 0) < 0)
			break;

		/* append other arguments */
		if (StringListAppendList(data->out->argList, tmpArgList, 0, -1) < 0)
			break;

		/* add sys libpath's to runpath list */
		if (StringListAppendList(runpathList, data->in->sysRunpath, 0, -1) < 0)
			break;

		if (StringListGetSize(runpathList) > 0) {
			if(StringListAppendListModify(data->out->argList, runpathList, 0, -1, "-R", 2, NULL, 0) < 0)
				break;
		}

		err = 0;
	} while(0);	/* end dummy loop */

	if (newString != NULL) newString = StringDestroy(newString);
	if (runpathList != NULL) runpathList = StringListDestroy(runpathList);
	if (tmpArgList != NULL) tmpArgList = StringListDestroy(tmpArgList);

	return err;
}

#if defined(__cplusplus)
}
#endif
