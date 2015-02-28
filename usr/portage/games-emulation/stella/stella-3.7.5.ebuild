# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-emulation/stella/stella-3.7.5.ebuild,v 1.4 2013/02/17 17:40:08 ago Exp $

EAPI=2
inherit eutils gnome2-utils games

DESCRIPTION="Stella Atari 2600 VCS Emulator"
HOMEPAGE="http://stella.sourceforge.net/"
SRC_URI="mirror://sourceforge/stella/${P}-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE="joystick opengl"

DEPEND="media-libs/libsdl[joystick?,opengl?,video]
	x11-libs/libX11
	media-libs/libpng:0
	sys-libs/zlib
	opengl? (
		virtual/opengl
		virtual/glu
	)"

src_prepare() {
	sed -i \
		-e '/INSTALL/s/-s //' \
		-e '/STRIP/d' \
		-e "/icons/d" \
		-e '/INSTALL.*DOCDIR/d' \
		-e '/INSTALL.*\/applications/d' \
		-e '/CXXFLAGS+=/s/-fomit-frame-pointer//' \
		Makefile || die
	sed -i \
		-e '/Icon/s/.png//' \
		-e '/Categories/s/Application;//' \
		src/unix/stella.desktop || die
	# build with newer zlib (bug #390093)
	sed -i -e '60i#define OF(x) x' src/emucore/unzip.h || die
}

src_configure() {
	# not an autoconf script
	./configure \
		--prefix="/usr" \
		--bindir="${GAMES_BINDIR}" \
		--docdir="/usr/share/doc/${PF}" \
		--datadir="${GAMES_DATADIR}" \
		$(use_enable opengl gl) \
		$(use_enable joystick) \
		|| die
}

src_install() {
	local i
	for i in 16 22 24 32 48 64 128 ; do
		newicon -s ${i} src/common/stella-${i}x${i}.png stella.png
	done

	emake DESTDIR="${D}" install || die
	domenu src/unix/stella.desktop
	dohtml -r docs/*
	dodoc Announce.txt Changes.txt Copyright.txt README-SDL.txt Readme.txt Todo.txt
	prepgamesdirs
}

pkg_preinst() {
	games_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	games_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
