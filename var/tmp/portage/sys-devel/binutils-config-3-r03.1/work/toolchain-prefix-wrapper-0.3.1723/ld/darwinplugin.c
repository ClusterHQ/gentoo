/*
 * Copyright 2007-2012 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * Author: Michael Haubenwallner <haubi@gentoo.org>
 */

#include <config.h>

#include "darwinplugin.h"

#include <stdlib.h>

#if defined(__cplusplus)
extern "C" {
#endif

int darwinplugin(LdPluginData* data)
{
	int err;

	do {	/* dummy loop */
		err = -1;

		if (StringListAppendConcat(data->out->argList, "-search_paths_first", 19, NULL) < 0) break;
		if (StringListAppendConcat(data->out->argList, "-macosx_version_min", 19, NULL) < 0) break;
		if (StringListAppendConcat(data->out->argList, MIN_OSX_TARGET, sizeof(MIN_OSX_TARGET), NULL) < 0) break;


		/* keep argv[1] ... argv[n] */
		if (StringListAppendList(data->out->argList, data->in->argList, 1, -1) < 0)
			break;

		/* append sys libpath's with "-L" */
		if (StringListAppendListModify(data->out->argList, data->in->sysLibpath, 0, -1, "-L", 2, NULL, 0) < 0)
			break;

		err = 0;
	} while(0);	/* end dummy loop */

	return err;
}

#if defined(__cplusplus)
}
#endif
