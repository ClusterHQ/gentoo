# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/harfbuzz/harfbuzz-0.9.12.ebuild,v 1.13 2014/01/20 19:21:18 vapier Exp $

EAPI=5

EGIT_REPO_URI="git://anongit.freedesktop.org/harfbuzz"
[[ ${PV} == 9999 ]] && inherit git-2 autotools

inherit autotools eutils libtool

DESCRIPTION="An OpenType text shaping engine"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/HarfBuzz"
[[ ${PV} == 9999 ]] || SRC_URI="http://www.freedesktop.org/software/${PN}/release/${P}.tar.bz2"

LICENSE="Old-MIT ISC icu"
SLOT="0"
[[ ${PV} == 9999 ]] || \
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 ~s390 ~sh sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~x64-macos ~x86-macos ~x64-solaris"
IUSE="static-libs"

RDEPEND="
	dev-libs/glib:2
	dev-libs/icu:=
	media-gfx/graphite2:=
	media-libs/freetype:2=
	x11-libs/cairo:=
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_prepare() {
	if [[ ${CHOST} == *-darwin* ]] ; then
		# on Darwin we need to link with g++, like automake defaults to,
		# but overridden by upstream because on Linux this is not
		# necessary, bug #449126
		sed -i \
			-e 's/\<LINK\>/CXXLINK/' \
			src/Makefile.am || die
		sed -i \
			-e '/libharfbuzz_la_LINK = /s/\<LINK\>/CXXLINK/' \
			src/Makefile.in || die
	fi
#	[[ ${PV} == 9999 ]] && eautoreconf
#	elibtoolize  # for building a shared library on x64-solaris

	# parallel make failure, fixed in 0.9.13, needs eautoreconf; bug #450920
	epatch "${FILESDIR}/${P}-hb-version.h.patch"
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable static-libs static)
}

src_install() {
	default
	prune_libtool_files --modules
}
