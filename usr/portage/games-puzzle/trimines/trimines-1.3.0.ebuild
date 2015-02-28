# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-puzzle/trimines/trimines-1.3.0.ebuild,v 1.7 2014/04/16 16:51:53 ulm Exp $

EAPI=2
inherit eutils games

DESCRIPTION="A mine sweeper game that uses triangles instead of squares"
HOMEPAGE="http://www.freewebs.com/trimines/"
SRC_URI="http://www.freewebs.com/trimines/${P}.tar.gz"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~ppc x86"
IUSE=""
RESTRICT="mirror bindist"

DEPEND="media-libs/libsdl[video]"
RDEPEND="${DEPEND}"

src_prepare() {
	sed -i \
		-e "s:data/:${GAMES_DATADIR}/${PN}/:" src/gfx.c \
		|| die "sed failed"
	epatch "${FILESDIR}"/${P}-gentoo.patch
}

src_install() {
	dogamesbin "${PN}" || die "dogamesbin failed"
	insinto "${GAMES_DATADIR}/${PN}"
	doins -r data/* || die "doins failed"
	dodoc README
	make_desktop_entry "${PN}" TriMines
	prepgamesdirs
}
