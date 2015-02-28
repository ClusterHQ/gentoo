# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-rpg/freedink-data/freedink-data-1.08.20121209.ebuild,v 1.3 2013/08/28 11:14:47 ago Exp $

EAPI=5

inherit games

DESCRIPTION="Freedink game data"
HOMEPAGE="http://www.freedink.org/"
SRC_URI="mirror://gnu/freedink/${P}.tar.gz"

LICENSE="ZLIB
	CC-BY-SA-3.0
	CC-BY-3.0
	FreeArt
	GPL-2
	GPL-3
	WTFPL-2
	OAL-1.0.1
	public-domain"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

src_install() {
	emake DESTDIR="${D}" DATADIR="${GAMES_DATADIR}" install
	dodoc README.txt README-REPLACEMENTS.txt
	prepgamesdirs
}
