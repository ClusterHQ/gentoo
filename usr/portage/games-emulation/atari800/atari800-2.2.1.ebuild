# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-emulation/atari800/atari800-2.2.1.ebuild,v 1.4 2012/01/10 20:39:19 ranger Exp $

EAPI=2
inherit games

DESCRIPTION="Atari 800 emulator"
HOMEPAGE="http://atari800.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz
	mirror://sourceforge/${PN}/xf25.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE="opengl readline sdl"

RDEPEND="sdl? ( >=media-libs/libsdl-1.2.0[opengl?,video] )
	!sdl? ( x11-libs/libX11 )
	media-libs/libpng:0
	readline? ( sys-libs/readline )"
DEPEND="${RDEPEND}
	!sdl? (
		x11-libs/libXt
		x11-libs/libX11
		x11-proto/xextproto
		x11-proto/xproto )
	app-arch/unzip"

src_prepare() {
	# remove some not-so-interesting ones
	rm -f DOC/{INSTALL.*,*.in,CHANGES.OLD}
	sed -i \
		-e "/CFG_FILE/s:/etc:${GAMES_SYSCONFDIR}:" \
		src/atari.c \
		|| die "sed failed"
	sed -i \
		-e 's/LDFLAGS="-s"/:/' \
		-e 's/-ltermcap//' \
		src/configure \
		|| die "sed failed"
	sed "s:/usr/share/games:${GAMES_DATADIR}:" \
		"${FILESDIR}"/atari800.cfg > "${T}"/atari800.cfg \
		|| die "sed failed"
}

src_configure() {
	local target="x11"
	use sdl && target="sdl"

	cd src && \
	egamesconf \
		$(use_enable readline monitor-readline) \
		$(use sdl && use_enable opengl) \
		--enable-crashmenu \
		--enable-monitorbreak \
		--enable-monitorhints \
		--enable-monitorasm \
		--enable-cursorblock \
		--enable-linuxjoystick \
		--enable-sound \
		--target=${target}
}

src_compile() {
	emake -C src || die "emake failed"
}

src_install () {
	dogamesbin src/atari800 || die "dogamesbin failed"
	newman src/atari800.man atari800.6
	dodoc README.1ST DOC/*
	insinto "${GAMES_DATADIR}/${PN}"
	doins "${WORKDIR}/"*.ROM || die "doins failed (ROM)"
	insinto "${GAMES_SYSCONFDIR}"
	doins "${T}"/atari800.cfg || die "doins failed (cfg)"
	prepgamesdirs
}
