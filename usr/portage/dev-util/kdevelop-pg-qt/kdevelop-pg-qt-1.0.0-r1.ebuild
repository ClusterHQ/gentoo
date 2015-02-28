# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/kdevelop-pg-qt/kdevelop-pg-qt-1.0.0-r1.ebuild,v 1.2 2014/04/25 20:35:37 johu Exp $

EAPI=5

inherit kde4-base

if [[ $PV == *9999* ]]; then
	KEYWORDS=""
else
	SRC_URI="mirror://kde/stable/${PN}/${PV}/src/${P}.tar.bz2"
	KEYWORDS="amd64 x86"
fi

DESCRIPTION="A LL(1) parser generator used mainly by KDevelop language plugins"
HOMEPAGE="http://www.kdevelop.org"
LICENSE="LGPL-2"
SLOT="0"
IUSE="debug"

RDEPEND=""
DEPEND="
	sys-devel/bison
	sys-devel/flex
"
