# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-block/di/di-4.35.ebuild,v 1.1 2014/03/09 02:32:09 radhermit Exp $

EAPI=4
inherit eutils toolchain-funcs

DESCRIPTION="Disk Information Utility"
HOMEPAGE="http://www.gentoo.com/di/"
SRC_URI="http://www.gentoo.com/di/${P}.tar.gz"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE=""

RESTRICT="test" #405205, #405471

src_prepare() {
	epatch "${FILESDIR}"/${PN}-4.33-build.patch
}

src_configure() {
	emake checkbuild
	emake -C C config.h
}

src_compile() {
	emake prefix=/usr CC="$(tc-getCC)"
}

src_install() {
	emake install prefix="${D}/usr"
	# default symlink is broken
	dosym di /usr/bin/mi
	dodoc README
}
