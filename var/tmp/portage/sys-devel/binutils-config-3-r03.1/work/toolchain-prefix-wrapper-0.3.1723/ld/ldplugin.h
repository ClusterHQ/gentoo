/*
 * Copyright 2008-2012 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * Authors: Michael Haubenwallner <haubi@gentoo.org>
 */

#ifndef _LDPLUGIN_H_
#define _LDPLUGIN_H_

#include <stringutil.h>

typedef struct _LdPluginData LdPluginData;

typedef int (*LdPluginFct)(LdPluginData*);

typedef struct _HostConfig {
	String* eprefix;
	String* triplet;
} HostConfig;

typedef struct _LdPluginIn {
	HostConfig  host;
	String*     root; /* "${ROOT%/}" */
	HostConfig  target;
	StringList* argList;
	StringList* userLibpath;
	StringList* sysLibpath;
	StringList* sysRunpath;

	/* cached flags */
	int haveRoot:1;
	int isCrossTriplet:1;
	int isCrossEprefix:1;
} LdPluginIn;

typedef struct _LdPluginOut {
	StringList* argList;
	char const* diagnostics;
} LdPluginOut;

struct _LdPluginData {
	LdPluginFct plugin;
	LdPluginIn const* in;
	LdPluginOut* out;
};

#endif /* _LDPLUGIN_H_ */
