# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/less/less-451.ebuild,v 1.8 2013/05/11 22:50:54 hwoarang Exp $

EAPI="4"

inherit eutils

DESCRIPTION="Excellent text file viewer"
HOMEPAGE="http://www.greenwoodsoftware.com/less/"
SRC_URI="http://www.greenwoodsoftware.com/less/${P}.tar.gz
	http://www-zeuthen.desy.de/~friebel/unix/less/code2color"

LICENSE="|| ( GPL-3 BSD-2 )"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="pcre unicode"

DEPEND=">=app-misc/editor-wrapper-3
	>=sys-libs/ncurses-5.2
	pcre? ( dev-libs/libpcre )"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${P}.tar.gz
	cp "${DISTDIR}"/code2color "${S}"/
}

src_prepare() {
	epatch "${FILESDIR}"/code2color.patch
}

src_configure() {
	export ac_cv_lib_ncursesw_initscr=$(usex unicode)
	export ac_cv_lib_ncurses_initscr=$(usex !unicode)
	econf \
		--with-regex=$(usex pcre pcre posix) \
		--with-editor="${EPREFIX}"/usr/libexec/editor
}

src_install() {
	default

	dobin code2color
	newbin "${FILESDIR}"/lesspipe.sh lesspipe
	dosym lesspipe /usr/bin/lesspipe.sh
	newenvd "${FILESDIR}"/less.envd 70less

	dodoc "${FILESDIR}"/README.Gentoo
}

pkg_postinst() {
	elog "lesspipe offers colorization options.  Run 'lesspipe -h' for info."
}
