# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/libkomparediff2/libkomparediff2-4.13.3.ebuild,v 1.1 2014/07/16 17:40:22 johu Exp $

EAPI=5

inherit kde4-base

DESCRIPTION="KDE library to compare files and strings"
KEYWORDS="~amd64 ~arm ~ppc ~x86 ~amd64-linux ~x86-linux"
IUSE="debug test"

RDEPEND="${DEPEND}
	!<=kde-base/kompare-4.11.50
"
