# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-strategy/dopewars/dopewars-1.5.12-r2.ebuild,v 1.7 2012/05/04 04:51:08 jdhore Exp $

EAPI=2
inherit eutils games

DESCRIPTION="Re-Write of the game Drug Wars"
HOMEPAGE="http://dopewars.sourceforge.net/"
SRC_URI="mirror://sourceforge/dopewars/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE="nls ncurses gtk gnome sdl"

RDEPEND="ncurses? ( >=sys-libs/ncurses-5.2 )
	gtk? ( x11-libs/gtk+:2 )
	dev-libs/glib:2
	nls? ( virtual/libintl )
	sdl? (
		media-libs/libsdl
		media-libs/sdl-mixer
	)"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	nls? ( sys-devel/gettext )"

src_prepare() {
	epatch "${FILESDIR}"/${P}-CVE-2009-3591.patch
	sed -i \
		-e "/priv_hiscore/ s:DPDATADIR:\"${GAMES_STATEDIR}\":" \
		-e "/\/doc\// s:DPDATADIR:\"/usr/share\":" \
		-e 's:index.html:html/index.html:' \
		src/dopewars.c \
		|| die "sed failed"
}

src_configure() {
	local myservconf

	if ! use gtk ; then
		myservconf="--disable-gui-client --disable-gui-server --disable-glibtest --disable-gtktest"
	fi

	egamesconf \
		--disable-dependency-tracking \
		$(use_enable ncurses curses-client) \
		$(use_enable nls) \
		$(use_with sdl) \
		--without-esd \
		--enable-networking \
		--enable-plugins \
		${myservconf}
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO

	dodir /usr/share
	cd "${D}/${GAMES_DATADIR}"
	use gnome && mv gnome "${D}/usr/share" || rm -rf gnome
	mv pixmaps "${D}/usr/share"
	dohtml -r doc/*/*
	rm -rf doc

	prepgamesdirs
}
