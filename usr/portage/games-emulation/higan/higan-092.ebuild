# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-emulation/higan/higan-092.ebuild,v 1.3 2013/08/28 11:14:00 ago Exp $

EAPI=5

inherit eutils gnome2-utils toolchain-funcs games

MY_P=${PN}_v${PV}-source

DESCRIPTION="A Nintendo multi-system emulator formerly known as bsnes"
HOMEPAGE="http://byuu.org/higan/ https://code.google.com/p/higan/"
SRC_URI="http://higan.googlecode.com/files/${MY_P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="ao +alsa openal opengl oss profile_accuracy +profile_balanced profile_performance pulseaudio qt4 +sdl xv"
REQUIRED_USE="|| ( ao openal alsa pulseaudio oss )
	|| ( xv opengl sdl )
	|| ( profile_accuracy profile_balanced profile_performance )"

RDEPEND="
	x11-libs/libX11
	x11-libs/libXext
	ao? ( media-libs/libao )
	openal? ( media-libs/openal )
	alsa? ( media-libs/alsa-lib )
	pulseaudio? ( media-sound/pulseaudio )
	xv? ( x11-libs/libXv )
	opengl? ( virtual/opengl )
	sdl? ( media-libs/libsdl[X,joystick,video] )
	!qt4? ( x11-libs/gtk+:2 )
	qt4? ( >=dev-qt/qtgui-4.5:4 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S=${WORKDIR}/${MY_P}

disable_module() {
	sed -i \
		-e "s|$1\b||" \
		"${S}"/${PN}/target-ethos/Makefile || die
}

src_prepare() {
	local i

	epatch "${FILESDIR}"/${P}-QA.patch

	sed -i \
		-e "/handle/s#/usr/local/lib#/usr/$(get_libdir)#" \
		${PN}/nall/dl.hpp || die "fixing libdir failed!"

	# audio modules
	use ao || disable_module audio.ao
	use openal || disable_module audio.openal
	use pulseaudio ||  { disable_module audio.pulseaudio
		disable_module audio.pulseaudiosimple ;}
	use oss || disable_module audio.oss
	use alsa || disable_module audio.alsa

	# video modules
	use opengl || disable_module video.glx
	use xv || disable_module video.xv
	use sdl || disable_module video.sdl

	# input modules
	use sdl || disable_module input.sdl

	# regenerate .moc if needed
	if use qt4; then
		cd ${PN}/phoenix/qt || die
		moc -i -I. -o platform.moc platform.moc.hpp || die
	fi

	for i in profile_accuracy profile_balanced profile_performance ; do
		if use ${i} ; then
			cp -dRP "${S}/${PN}" "${S}/${PN}_${i}" || die
		fi
	done
}

src_compile() {
	local mytoolkit i

	if use qt4; then
		mytoolkit="qt"
	else
		mytoolkit="gtk"
	fi

	for i in profile_accuracy profile_balanced profile_performance ; do
		if use ${i} ; then
			cd "${S}/${PN}_${i}" || die
			emake \
				platform="x" \
				compiler="$(tc-getCXX)" \
				profile="${i#profile_}" \
				phoenix="${mytoolkit}"

			sed \
				-e "s:%GAMES_DATADIR%:${GAMES_DATADIR}:" \
				< "${FILESDIR}"/${PN}-wrapper \
				> out/${PN}-wrapper || die "generating wrapper failed!"
		fi
	done
}

src_install() {
	local i

	for i in profile_accuracy profile_balanced profile_performance ; do
		if use ${i} ; then
			# install higan
			newgamesbin "${S}/${PN}_${i}"/out/${PN} ${PN}-${i#profile_}.bin
			newgamesbin "${S}/${PN}_${i}"/out/${PN}-wrapper ${PN}-${i#profile_}
			make_desktop_entry "${PN}-${i#profile_}" "${PN} (${i#profile_})"
		fi
	done

	# copy home directory stuff to a global location
	insinto "${GAMES_DATADIR}"/${PN}
	doins -r ${PN}/data/cheats.bml ${PN}/profile/*

	# install shaders
	if use opengl; then
		insinto "${GAMES_DATADIR}/${PN}/Video Shaders"
		doins shaders/*OpenGL*.shader
	fi

	doicon -s 48 ${PN}/data/${PN}.png

	prepgamesdirs
}

pkg_preinst() {
	games_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	elog "optional dependencies:"
	elog "  dev-games/higan-ananke (extra rom load options)"
	elog "  games-util/higan-purify (Rom purifier)"

	games_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
