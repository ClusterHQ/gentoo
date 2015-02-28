/*
 * Copyright 2007-2012 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * Author: Michael Haubenwallner <haubi@gentoo.org>
 */

#if !defined(_GNUPLUGIN_H_)
#define _GNUPLUGIN_H

#include <ldplugin.h>

#if defined(__cplusplus)
extern "C" {
#endif

extern int gnuplugin(LdPluginData*);

#if defined(__cplusplus)
}
#endif

#endif /* _GNUPLUGIN_H_ */
