# Copyright: 2005-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# all vars that are to wind up in portage_const must have their name listed in __all__

__all__ = ["EPREFIX", "SYSCONFDIR", "PORTAGE_BASE",
		"portageuser", "portagegroup", "rootuser", "rootuid", "rootgid",
		"PORTAGE_BASH", "PORTAGE_MV"]

from os import path

EPREFIX      = "/home/core/gentoo"
SYSCONFDIR   = "/home/core/gentoo/etc"
PORTAGE_BASE = "/home/core/gentoo/usr/lib/portage"

portagegroup = "core"
portageuser  = "core"
rootuser     = "core"
rootuid      = 1001
rootgid      = 1001

PORTAGE_BASH = "/home/core/gentoo/bin/bash"
PORTAGE_MV   = "/home/core/gentoo/bin/mv"
