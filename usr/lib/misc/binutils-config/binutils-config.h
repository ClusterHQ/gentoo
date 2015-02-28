/*
 * Copyright 2008-2012 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * Authors: Michael Haubenwallner <haubi@gentoo.org>
 */

#ifndef _BINUTILS_CONFIG_H_
#define _BINUTILS_CONFIG_H_

/* return comma separated list of plugin names to be called */
extern char const* CTARGET(void);
extern char const* LDPLUGINS(void);
extern int DEBUG(void);

#endif /* _BINUTILS_CONFIG_H_ */
