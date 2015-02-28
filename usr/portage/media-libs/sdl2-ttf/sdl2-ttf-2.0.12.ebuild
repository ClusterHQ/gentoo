# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/sdl2-ttf/sdl2-ttf-2.0.12.ebuild,v 1.3 2013/09/02 20:45:58 hasufell Exp $

EAPI=5
inherit autotools eutils

MY_P=SDL2_ttf-${PV}
DESCRIPTION="library that allows you to use TrueType fonts in SDL applications"
HOMEPAGE="http://www.libsdl.org/projects/SDL_ttf/"
SRC_URI="http://www.libsdl.org/projects/SDL_ttf/release/${MY_P}.tar.gz"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="static-libs X"

RDEPEND="X? ( x11-libs/libXt )
	media-libs/libsdl2
	>=media-libs/freetype-2.3"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_prepare() {
	epatch "${FILESDIR}"/${P}-linking.patch
	eautoreconf
	rm -r external || die
}

src_configure() {
	econf \
		$(use_enable static-libs static) \
		$(use_with X x)
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc {CHANGES,README}.txt
	use static-libs || prune_libtool_files
}
