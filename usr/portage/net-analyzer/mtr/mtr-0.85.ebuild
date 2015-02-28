# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/mtr/mtr-0.85.ebuild,v 1.16 2013/11/17 08:11:36 naota Exp $

EAPI=5
inherit eutils autotools flag-o-matic

DESCRIPTION="My TraceRoute, an Excellent network diagnostic tool"
HOMEPAGE="http://www.bitwizard.nl/mtr/"
SRC_URI="ftp://ftp.bitwizard.nl/mtr/${P}.tar.gz
	mirror://gentoo/gtk-2.0-for-mtr.m4.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 ~s390 ~sh sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="gtk ipv6 suid"

RDEPEND="
	sys-libs/ncurses
	gtk? (
		dev-libs/glib:2
		x11-libs/gtk+:2
	)"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

DOCS=( AUTHORS FORMATS NEWS README SECURITY TODO )

src_prepare() {
	epatch \
		"${FILESDIR}"/0.80-impl-dec.patch \
		"${FILESDIR}"/0.85-ipv6.patch \
		"${FILESDIR}"/0.85-gtk.patch

	# https://github.com/traviscross/mtr/commit/2a08115f2c026232e2172db7f894d12306594d1d
	# https://bugs.gentoo.org/show_bug.cgi?id=476736
	sed -i -e '/#ifndef __APPLE__/s/ifndef/ifdef/' asn.c || die'

	# Keep this comment and following mv, even in case ebuild does not need
	# it: kept gtk-2.0.m4 in SRC_URI but you'll have to mv it before autoreconf
	mv "${WORKDIR}"/gtk-2.0-for-mtr.m4 gtk-2.0.m4 #222909
	AT_M4DIR="." eautoreconf
}
src_configure() {
	# In the source's configure script -lresolv is commented out. Apparently it
	# is needed for 64bit macos still.
	[[ ${CHOST} == *-darwin* ]] && append-libs -lresolv
	econf \
		$(use_with gtk glib) \
		$(use_with gtk) \
		$(use_enable ipv6)

	# It's a bit absurd to have to do this, but the package isn't
	# actually "configured" and ready to be compiled until this is
	# done because upstream packaged .o files with the tarball.
	# Remember to take this out on future versions.
	emake clean
}

src_install() {
	default

	if use !prefix ; then
		fowners root:0 /usr/sbin/mtr
		if use suid; then
			fperms 4711 /usr/sbin/mtr
		else
			fperms 0710 /usr/sbin/mtr
		fi
	fi
}
