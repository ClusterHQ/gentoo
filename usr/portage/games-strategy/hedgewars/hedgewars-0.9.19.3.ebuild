# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-strategy/hedgewars/hedgewars-0.9.19.3.ebuild,v 1.4 2014/05/15 17:04:23 ulm Exp $

# TODO: when physfs-2.1.0 hits the tree, set
# -DPHYSFS_SYSTEM=ON

EAPI=5
CMAKE_BUILD_TYPE=Release
inherit cmake-utils eutils games

MY_P=${PN}-src-${PV}
DESCRIPTION="A turn-based strategy, artillery, action and comedy game"
HOMEPAGE="http://hedgewars.org/"
SRC_URI="http://download.gna.org/hedgewars/${MY_P}.tar.bz2"

LICENSE="GPL-2 Apache-2.0 FDL-1.3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
QA_FLAGS_IGNORED=${GAMES_BINDIR}/hwengine # pascal sucks
QA_PRESTRIPPED=${GAMES_BINDIR}/hwengine # pascal sucks

RDEPEND="
	dev-lang/lua
	dev-qt/qtgui:4
	media-libs/freeglut
	media-libs/libsdl[sound,opengl,video]
	media-libs/sdl-image[png]
	media-libs/sdl-mixer[vorbis]
	media-libs/sdl-net
	media-libs/sdl-ttf
	sys-libs/zlib
	virtual/ffmpeg"
DEPEND="${RDEPEND}
	>=dev-lang/fpc-2.4"
RDEPEND="${RDEPEND}
	>=media-fonts/dejavu-2.28"

S=${WORKDIR}/${PN}-src-${PV}

src_configure() {
	local mycmakeargs=(
		-DMINIMAL_FLAGS=ON
		-DCMAKE_INSTALL_PREFIX="${GAMES_PREFIX}"
		-DDATA_INSTALL_DIR="${GAMES_DATADIR}"
		-DNOSERVER=TRUE
		-DCMAKE_VERBOSE_MAKEFILE=TRUE
		-DPHYSFS_SYSTEM=OFF
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	DOCS="ChangeLog.txt README" cmake-utils_src_install
	rm -f "${D}"/usr/share/games/hedgewars/Data/Fonts/DejaVuSans-Bold.ttf
	dosym /usr/share/fonts/dejavu/DejaVuSans-Bold.ttf \
		"${GAMES_DATADIR}"/hedgewars/Data/Fonts/DejaVuSans-Bold.ttf
	newicon QTfrontend/res/hh25x25.png ${PN}.png
	make_desktop_entry ${PN} Hedgewars
	doman man/${PN}.6
	prepgamesdirs
}
