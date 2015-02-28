# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-mail/fdm/fdm-1.6-r1.ebuild,v 1.4 2013/06/26 14:37:35 xmw Exp $

EAPI=2

inherit eutils toolchain-funcs user

DESCRIPTION="fetch, filter and deliver mail"
HOMEPAGE="http://fdm.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="courierauth examples pcre"

DEPEND="dev-libs/openssl
	sys-libs/tdb
	courierauth? ( net-libs/courier-authlib )
	pcre? ( dev-libs/libpcre )"
RDEPEND="${DEPEND}"

pkg_setup() {
	enewuser _fdm
}

src_prepare() {
	rm Makefile || die
	epatch "${FILESDIR}"/${PF}-GNUmakefile.patch \
		"${FILESDIR}"/${PF}-underlinking.patch
}

src_compile() {
	emake CC="$(tc-getCC)" \
		COURIER=$(use courierauth && echo 1) \
		PCRE=$(use pcre && echo 1) || die
}

src_install() {
	emake DESTDIR="${D}" PREFIX=/usr install || die
	dodoc CHANGES MANUAL README TODO || die
	if use examples ; then
		docinto examples
		dodoc examples/* || die
	fi
}
