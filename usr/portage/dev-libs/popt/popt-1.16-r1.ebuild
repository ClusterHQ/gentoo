# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/popt/popt-1.16-r1.ebuild,v 1.9 2012/04/26 14:04:24 aballier Exp $

EAPI=3

inherit eutils libtool

DESCRIPTION="Parse Options - Command line parser"
HOMEPAGE="http://rpm5.org/"
SRC_URI="http://rpm5.org/files/popt/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static-libs"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="nls? ( sys-devel/gettext )"

src_prepare() {
	epatch "${FILESDIR}"/fix-popt-pkgconfig-libdir.patch #349558
	sed -i -e 's:lt-test1:test1:' testit.sh || die

	epatch "${FILESDIR}"/${PN}-1.15-mint.patch
	epatch "${FILESDIR}"/${PN}-1.13-no-wchar-hack.patch # for Interix and MiNT
	elibtoolize # for FreeMiNT
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable nls)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc CHANGES README || die

	find "${ED}" -name '*.la' -exec rm -f {} +
}
