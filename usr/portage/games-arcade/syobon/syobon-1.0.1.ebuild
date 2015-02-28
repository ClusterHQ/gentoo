# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-arcade/syobon/syobon-1.0.1.ebuild,v 1.6 2014/05/15 16:33:13 ulm Exp $

EAPI=2
inherit games

MY_P="${PN}_${PV}_src"

DESCRIPTION="Syobon Action (also known as Cat Mario or Neko Mario)"
HOMEPAGE="http://zapek.com/?p=189"
SRC_URI="http://download.zapek.com/software/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="media-libs/libsdl[sound,video,joystick]
	media-libs/sdl-gfx
	media-libs/sdl-image[png]
	media-libs/sdl-ttf
	media-libs/sdl-mixer[vorbis]"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

S=${WORKDIR}/${PN}

src_compile() {
	emake GAMEDATA="${GAMES_DATADIR}/${PN}" || die
}

src_install() {
	dogamesbin ${PN} || die

	insinto "${GAMES_DATADIR}/${PN}"
	doins -r BGM SE res || die
	dodoc README.txt || die
	prepgamesdirs
}
