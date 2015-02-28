# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/libpar2/libpar2-0.2.1.ebuild,v 1.5 2012/12/04 11:24:38 ago Exp $

EAPI=4

inherit autotools-utils

DESCRIPTION="A library for par2, extracted from par2cmdline"
HOMEPAGE="http://parchive.sourceforge.net/"
SRC_URI="https://launchpad.net/${PN}/${PV:0:3}/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE="static-libs"

RDEPEND="dev-libs/libsigc++:2"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

DOCS=( AUTHORS ChangeLog README )

# Needed to install all headers properly (bug #391815)
AUTOTOOLS_IN_SOURCE_BUILD=1
