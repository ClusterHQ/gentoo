/*
 * Copyright 2007-2012 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * Author: Michael Haubenwallner <haubi@gentoo.org>
 */

#include <config.h>

#include "aixplugin.h"

#include <stdlib.h>
#include <string.h>

#if defined(__cplusplus)
extern "C" {
#endif

/* AIX-ld:
 * When there is no explicit runpath on the linker commandline (-blibpath:runpath),
 * then all library paths (-L) are recorded as runpath if not in svr4 mode.
 *
 * Extension to default-mode (non-svr4):
 * Accept additional runpaths specified with -R
 */
int aixplugin(LdPluginData* data)
{
	int argc = 0;
	int err;
	StringList *defaultRunpathList = NULL;
	StringList *runpathList = NULL;
	StringList *aixRunpathList = NULL;
	String const *argString;
	String *newString = NULL;
	char libpath2runpath = 1; /* whether to record -L as runpath */
	char svr4mode = 0; /* whether we are in -bsvr4 mode */
	char const *argBuffer;
	int argBufferLength;

	do {	/* dummy loop */
		err = -1;

		defaultRunpathList = StringListCreate(NULL, 0, 0);
		if (defaultRunpathList == NULL)
			break;

		runpathList = StringListCreate(NULL, 0, 0);
		if (runpathList == NULL)
			break;

		aixRunpathList = StringListCreate(NULL, 0, 0);
		if (aixRunpathList == NULL
		 || StringListAppendConcat(aixRunpathList, "/usr/lib", strlen("/usr/lib"), NULL) < 0
		 || StringListAppendConcat(aixRunpathList, "/lib", strlen("/lib"), NULL) < 0
		) break;

		/* always use runtime linking (-brtl) */
		if (StringListAppendConcat(data->out->argList, "-brtl", strlen("-brtl"), NULL) < 0)
			break;

		/* detect if we are in svr4 mode (-bsvr4).
		 * "-R runpath" is only accepted in svr4 mode,
		 * but we add "-R runpath" as extension in normal mode to add default runpath.
		 */
		for(argc = 1; argc < StringListGetSize(data->in->argList); argc++) {
			argString = StringListGetString(data->in->argList, argc);
			argBuffer = StringGetBuffer(argString);
			if (strcmp(argBuffer, "-bsvr4") == 0) {
				svr4mode = 1;
				libpath2runpath = 0;
			}
		}

		for(argc = 1; argc < StringListGetSize(data->in->argList); argc++) {
			argString = StringListGetString(data->in->argList, argc);
			argBuffer = StringGetBuffer(argString);
			argBufferLength = StringGetLength(argString);

			if (strcmp(argBuffer, "-bnolibpath") == 0) {
				/* explicitly specified: do not record -L args as runpath.  */
				libpath2runpath = 0;
				/* This also removes each runpath specified before. */
				StringListClear(runpathList);
				if (svr4mode) {
					StringListClear(defaultRunpathList);
				} /* else we accept -R as extension */
				continue;
			} else
			if (strncmp(argBuffer, "-blibpath:", strlen("-blibpath:")) == 0) {
				char const *curr, *next;

				argBuffer += strlen("-blibpath:");

				/* do not record -L args as runpath, we have explicit -blibpath: */
				libpath2runpath = 0;

				/* '-blibpath:' kills previous '-blibpath:' */
				StringListClear(runpathList);

				if (svr4mode) {
					/* it also kills previous '-Rrunpathlist' in svr4mode */
					StringListClear(defaultRunpathList);
				} /* else we accept -R as extension */

				for(curr = next = argBuffer; *next != '\0'; curr = next+1) {
					for(next = curr; *next != '\0' && *next != ':'; next++);

					if (next - curr <= 1) {
						/* skip empty path */
						continue;
					}

					/* unique out runpath */
					if (StringListContains(runpathList, curr, next - curr)
					 || StringListContains(data->in->sysLibpath, curr, next - curr)
					 || StringListContains(aixRunpathList, curr, next - curr)
					)
						continue;

					/* record this path into runpath list */
					if (StringListAppendConcat(runpathList, curr, next - curr, NULL) < 0)
						break;
				}

				/* end "-blibpath:" handling */
				continue;
			} else
			if (strncmp(argBuffer, "-R", strlen("-R")) == 0) {
				if (svr4mode) {
					/* in svr4 mode, '-R' kills previous '-blibpath:' arguments.
					 * in normal mode, we implement '-R runpath' as an extension.
					 */
					StringListClear(runpathList);
				}
				argBuffer += strlen("-R");
				argBufferLength -= strlen("-R");

				if (*argBuffer == 0 && argc < StringListGetSize(data->in->argList)) {
					argc++;
					argString = StringListGetString(data->in->argList, argc);
					argBuffer = StringGetBuffer(argString);
					argBufferLength = StringGetLength(argString);
				}
				if (StringListContains(defaultRunpathList, argBuffer, argBufferLength)
				 || StringListContains(data->in->sysLibpath, argBuffer, argBufferLength)
				 || StringListContains(aixRunpathList, argBuffer, argBufferLength)
				)
					continue;

				if (StringListAppendConcat(defaultRunpathList, argBuffer, argBufferLength, NULL) < 0)
					break;

				continue;
			}

			/* keep other arguments */
			if (StringListAppendString(data->out->argList, argString) < 0) break;
		}
		if (argc < StringListGetSize(data->in->argList)) {
			/* error during argument parsing */
			break;
		}

		if (libpath2runpath /* need to record '-L' args as runpath too */
		 && StringListAppendList(runpathList, data->in->userLibpath, 0, -1) < 0
		) break;

		/* always have default runpath list in runpath */
		if (StringListAppendList(runpathList, defaultRunpathList, 0, -1) < 0)
			break;

		/* always have sys runpath list in runpath */
		if (StringListAppendList(runpathList, data->in->sysRunpath, 0, -1) < 0)
			break;

		/* need to add /usr/lib:/lib myself even in svr4 mode, as we drop -R args */
		if (StringListAppendList(runpathList, aixRunpathList, 0, -1) < 0
		) break;

		/* create runpath string: "-blibpath:libpath1:libpathN" */
		newString = StringListJoin(runpathList
			, "-blibpath:", strlen("-blibpath:") /* start */
			, ":", strlen(":")                   /* separator */
			, NULL, 0                            /* end */
		);
		if (newString == NULL)
			break;

		/* append runpath string to commandline */
		if (StringListAppendString(data->out->argList, newString) < 0)
			break;

		/* append sys libpath's with "-L" */
		if (StringListAppendListModify(data->out->argList, data->in->sysLibpath, 0, -1, "-L", 2, NULL, 0) < 0)
			break;

		err = 0;
	} while(0);	/* end dummy loop */

	newString = StringDestroy(newString);
	runpathList = StringListDestroy(runpathList);
	defaultRunpathList = StringListDestroy(defaultRunpathList);
	aixRunpathList = StringListDestroy(aixRunpathList);

	return err;
}

#if defined(__cplusplus)
}
#endif
