# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-rpg/gwiz/gwiz-0.8.ebuild,v 1.11 2013/02/13 21:08:32 mr_bones_ Exp $

EAPI=5
inherit eutils games

DESCRIPTION="clone of old-school Wizardry(tm) games by SirTech"
HOMEPAGE="http://icculus.org/gwiz/"
SRC_URI="http://icculus.org/gwiz/${P}.tar.bz2"

KEYWORDS="alpha ~amd64 ppc x86"
SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND=">=media-libs/libsdl-1.2.3[joystick,video]
	>=media-libs/sdl-image-1.2.1-r1[png]
	>=media-libs/sdl-ttf-2.0.4"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}"/${P}-buffer.patch )

src_install() {
	default
	dodoc AUTHORS ChangeLog README doc/HOWTO-PLAY
	newicon pixmaps/gwiz_icon.xpm ${PN}.xpm
	make_desktop_entry gwiz Gwiz
}
