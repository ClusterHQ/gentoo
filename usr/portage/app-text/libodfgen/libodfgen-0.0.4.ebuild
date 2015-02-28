# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/libodfgen/libodfgen-0.0.4.ebuild,v 1.3 2014/06/29 16:43:37 ago Exp $

EAPI=5

inherit eutils

DESCRIPTION="Library to generate ODF documents from libwpd and libwpg"
HOMEPAGE="http://libwpd.sf.net"
SRC_URI="mirror://sourceforge/libwpd/${P}.tar.xz"

LICENSE="|| ( LGPL-2.1 MPL-2.0 )"
SLOT="0"
KEYWORDS="amd64 ~arm ~ppc x86 ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="
	app-text/libetonyek
	app-text/libwpd
	app-text/libwpg
"
DEPEND="${RDEPEND}
	>=dev-libs/boost-1.46
	virtual/pkgconfig
"

src_configure() {
	econf \
		--disable-static \
		--disable-werror \
		--with-sharedptr=boost \
		--docdir="${EPREFIX}"/usr/share/doc/${PF}
}

src_install() {
	default
	prune_libtool_files --all
}
