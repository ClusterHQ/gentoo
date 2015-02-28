# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/deltup/deltup-0.4.5-r1.ebuild,v 1.3 2014/08/10 18:20:53 slyfox Exp $

EAPI=5

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="Delta-Update - patch system for updating source-archives"
HOMEPAGE="http://deltup.sourceforge.net"
SRC_URI="http://deltup.org/e107_files/downloads//${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~ppc ~sparc ~x86"
IUSE=""

DEPEND="dev-libs/openssl
	sys-libs/zlib
	>=app-arch/bzip2-1.0.0"
RDEPEND="${DEPEND}
	|| ( dev-util/bdelta =dev-util/xdelta-1* )
	>=app-arch/bzip2-1.0.4"

src_prepare () {
	epatch "${FILESDIR}"/${PN}-0.4.4-gcc47.patch
	epatch "${FILESDIR}"/${PN}-0.4.4-zlib-1.2.5.2.patch
	epatch "${FILESDIR}"/${PN}-0.4.5-underlink.patch
	epatch_user
}

src_compile () {
	emake CXX=$(tc-getCXX)
}

src_install () {
	emake DESTDIR="${D}" install
	dodoc README ChangeLog
	doman deltup.1
}
