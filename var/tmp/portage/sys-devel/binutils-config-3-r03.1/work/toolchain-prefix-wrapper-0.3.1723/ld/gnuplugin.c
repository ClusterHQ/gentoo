/*
 * Copyright 2007-2012 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * Author: Michael Haubenwallner <haubi@gentoo.org>
 */

#include <config.h>

#include "gnuplugin.h"

#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/param.h>

#if defined(__cplusplus)
extern "C" {
#endif

int gnuplugin(LdPluginData* data)
{
	const char _rpath[] = "-rpath";
	const int _rpath_len = strlen(_rpath);
	const char _R[] = "-R";
	const int _R_len = strlen(_R);

	int argc = 0;
	int err;
	StringList *runpathList = NULL;
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

		err = 0;
		for(argc = 1; !err && argc < StringListGetSize(data->in->argList); argc++) {
			err = -1;

			argString = StringListGetString(data->in->argList, argc);
			argBuffer = StringGetBuffer(argString);
			argLength = StringGetLength(argString);

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
							if (StringListAppendConcat(data->out->argList
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

					/* keep empty paths (QA checks will ensure they
					 * never make it) and duplicates, some stupid tools
					 * (like cmake) pass an rpath string and do some
					 * string matching magic to see if their originally
					 * inserted rpath is available. */

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

			/* keep other arguments on commandline */
			if (StringListAppendString(data->out->argList, argString) < 0)
				break;

			err = 0;
		}
		if (argc < StringListGetSize(data->in->argList)) {
			/* error during argument parsing */
			break;
		}

		/* add sys libpath's to runpath list */
		if (StringListAppendList(runpathList, data->in->sysRunpath, 0, -1) < 0)
			break;

		if (StringListGetSize(runpathList) > 0) {
			/* put runpath arg on commandline */
			if (StringListAppendConcat(data->out->argList, "-rpath", 6, NULL) < 0) break;

			/* create string containing libpath1:libpathN */
			newString = StringListJoin(runpathList, NULL, 0, ":", 1, NULL, 0);
			if (newString == NULL) {
				break;
			}

			/* put runpath on commandline */
			if (StringListAppendString(data->out->argList, newString) < 0) break;
		}

		/* append sys libpath's with "-L" */
		if (StringListAppendListModify(data->out->argList, data->in->sysLibpath, 0, -1, "-L", 2, NULL, 0) < 0)
			break;

		err = 0;
	} while(0);	/* end dummy loop */

	if (newString != NULL) newString = StringDestroy(newString);
	if (runpathList != NULL) runpathList = StringListDestroy(runpathList);

	return err;
}

#if defined(__cplusplus)
}
#endif
