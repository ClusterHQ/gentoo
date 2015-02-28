# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-engines/solarus/solarus-1.2.1.ebuild,v 1.1 2014/08/07 21:01:19 hasufell Exp $

EAPI=5

inherit cmake-utils games

DESCRIPTION="An open-source Zelda-like 2D game engine"
HOMEPAGE="http://www.solarus-games.org/"
SRC_URI="http://www.zelda-solarus.com/downloads/${PN}/${P}-src.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="luajit"

RDEPEND="
	dev-games/physfs
	media-libs/libmodplug
	>=media-libs/libsdl2-2.0.1[X,joystick,video]
	media-libs/libvorbis
	media-libs/openal
	media-libs/sdl2-image[png]
	>=media-libs/sdl2-ttf-2.0.12
	luajit? ( dev-lang/luajit:2 )
	!luajit? ( dev-lang/lua )"
DEPEND="${RDEPEND}"

DOCS=( ChangeLog readme.txt )
PATCHES=( "${FILESDIR}"/${P}-paths.patch )

src_prepare() {
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DSOLARUS_INSTALL_DESTINATION="${GAMES_BINDIR}"
		$(cmake-utils_use luajit SOLARUS_USE_LUAJIT)
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
	prepgamesdirs
}
