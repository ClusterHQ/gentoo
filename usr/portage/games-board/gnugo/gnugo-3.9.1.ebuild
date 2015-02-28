# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-board/gnugo/gnugo-3.9.1.ebuild,v 1.8 2014/03/18 01:14:30 mr_bones_ Exp $

EAPI=2
inherit games

DESCRIPTION="A Go-playing program"
HOMEPAGE="http://www.gnu.org/software/gnugo/devel.html"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~arm ppc ppc64 x86 ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="readline"

DEPEND="readline? ( sys-libs/readline >=sys-libs/ncurses-5.2-r3 )"

src_configure() {
	egamesconf \
		--disable-dependency-tracking \
		$(use_with readline) \
		--enable-cache-size=32
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
	prepgamesdirs
}
