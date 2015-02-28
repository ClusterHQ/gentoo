# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/knetattach/knetattach-4.13.3.ebuild,v 1.1 2014/07/16 17:40:16 johu Exp $

EAPI=5

KDE_HANDBOOK="optional"
KMNAME="kde-runtime"
inherit kde4-meta

DESCRIPTION="KDE network wizard"
KEYWORDS=" ~amd64 ~arm ~ppc ~ppc64 ~x86 ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE="debug"
