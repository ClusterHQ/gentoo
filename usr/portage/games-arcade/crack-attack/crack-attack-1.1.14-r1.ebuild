# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-arcade/crack-attack/crack-attack-1.1.14-r1.ebuild,v 1.10 2012/05/04 04:22:29 jdhore Exp $

EAPI=2
inherit eutils games

DESCRIPTION="Addictive OpenGL-based block game"
HOMEPAGE="http://www.nongnu.org/crack-attack/"
SRC_URI="http://savannah.nongnu.org/download/crack-attack/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm hppa ia64 ppc sparc x86"
IUSE="gtk sdl"

RDEPEND="media-libs/freeglut
	sdl? ( media-libs/libsdl
		media-libs/sdl-mixer )
	gtk? ( >=x11-libs/gtk+-2.6:2 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	epatch \
		"${FILESDIR}"/${P}-glut.patch \
		"${FILESDIR}"/${P}-gcc43.patch
	sed -i 's/-lXmu//' src/gtk-gui/Makefile.in src/Makefile.in || die
	touch -r . * */*
}

src_configure() {
	egamesconf \
		--disable-binreloc \
		$(use_enable sdl sound) \
		$(use_enable gtk)
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog README
	dohtml -A xpm doc/*
	doicon data/crack-attack.xpm
	make_desktop_entry crack-attack Crack-attack
	prepgamesdirs
}
