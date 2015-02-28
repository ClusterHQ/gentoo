# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsdl/libsdl-1.2.15-r1.ebuild,v 1.2 2012/05/09 13:15:36 aballier Exp $

EAPI=2
inherit flag-o-matic multilib toolchain-funcs eutils libtool

DESCRIPTION="Simple Direct Media Layer"
HOMEPAGE="http://www.libsdl.org/"
SRC_URI="http://www.libsdl.org/release/SDL-${PV}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
# WARNING:
# If you turn on the custom-cflags use flag in USE and something breaks,
# you pick up the pieces.  Be prepared for bug reports to be marked INVALID.
IUSE="oss alsa nas X dga xv xinerama fbcon directfb ggi svga tslib aalib opengl libcaca +audio +video +joystick custom-cflags pulseaudio ps3 static-libs"

RDEPEND="audio? ( >=media-libs/audiofile-0.1.9 )
	alsa? ( media-libs/alsa-lib )
	nas? (
		media-libs/nas
		x11-libs/libXt
		x11-libs/libXext
		x11-libs/libX11
	)
	X? (
		x11-libs/libXt
		x11-libs/libXext
		x11-libs/libX11
		x11-libs/libXrandr
	)
	directfb? ( >=dev-libs/DirectFB-0.9.19 )
	ggi? ( >=media-libs/libggi-2.0_beta3 )
	svga? ( >=media-libs/svgalib-1.4.2 )
	aalib? ( media-libs/aalib )
	libcaca? ( >=media-libs/libcaca-0.9-r1 )
	opengl? ( virtual/opengl virtual/glu )
	ppc64? ( ps3? ( sys-libs/libspe2 ) )
	tslib? ( x11-libs/tslib )
	pulseaudio? ( media-sound/pulseaudio )"
DEPEND="${RDEPEND}
	nas? (
		x11-proto/xextproto
		x11-proto/xproto
	)
	X? (
		x11-proto/xextproto
		x11-proto/xproto
	)
	x86? ( || ( >=dev-lang/yasm-0.6.0 >=dev-lang/nasm-0.98.39-r3 ) )"

S=${WORKDIR}/SDL-${PV}

pkg_setup() {
	if use custom-cflags ; then
		ewarn "Since you've chosen to use possibly unsafe CFLAGS,"
		ewarn "don't bother filing libsdl-related bugs until trying to remerge"
		ewarn "libsdl without the custom-cflags use flag in USE."
		epause 10
	fi
}

src_prepare() {
	epatch \
		"${FILESDIR}"/${P}-sdl-config.patch \
		"${FILESDIR}"/${P}-resizing.patch

	# darwin uses dlopen too
	epatch "${FILESDIR}"/${PN}-1.2.13-darwin-loadobj.patch
	sed -e "s|@GENTOO_PREFIX_LIBDIR@|${EPREFIX}/usr/$(get_libdir)|g" \
		-i "${S}/src/loadso/dlopen/SDL_sysloadso.c" \
		-i "${S}/src/loadso/mint/SDL_sysloadso.c" \
		|| die "sed loadso failed"

	./autogen.sh
	elibtoolize
}

src_configure() {
	local myconf=
	if [[ $(tc-arch) != "x86" ]] ; then
		myconf="${myconf} --disable-nasm"
	else
		myconf="${myconf} --enable-nasm"
	fi
	use custom-cflags || strip-flags
	use audio || myconf="${myconf} --disable-audio"
	use video \
		&& myconf="${myconf} --enable-video-dummy" \
		|| myconf="${myconf} --disable-video"
	use joystick || myconf="${myconf} --disable-joystick"

	local directfbconf="--disable-video-directfb"
	if use directfb ; then
		# since DirectFB can link against SDL and trigger a
		# dependency loop, only link against DirectFB if it
		# isn't broken #61592
		echo 'int main(){}' > directfb-test.c
		$(tc-getCC) directfb-test.c -ldirectfb 2>/dev/null \
			&& directfbconf="--enable-video-directfb" \
			|| ewarn "Disabling DirectFB since libdirectfb.so is broken"
	fi

	myconf="${myconf} ${directfbconf}"

	# somehow the build depends on it, but doesn't understand it needs it
	[[ ${CHOST} == *-darwin* ]] && \
		myconf="${myconf} --disable-video-carbon --enable-video-cocoa"

	# enable rpath for Prefix!
	econf \
		--enable-rpath \
		--disable-arts \
		--disable-esd \
		--enable-events \
		--enable-cdrom \
		--enable-threads \
		--enable-timers \
		--enable-file \
		--enable-cpuinfo \
		--disable-alsa-shared \
		--disable-esd-shared \
		--disable-pulseaudio-shared \
		--disable-arts-shared \
		--disable-nas-shared \
		--disable-osmesa-shared \
		$(use_enable oss) \
		$(use_enable alsa) \
		$(use_enable pulseaudio) \
		$(use_enable nas) \
		$(use_enable X video-x11) \
		$(use_enable dga) \
		$(use_enable xv video-x11-xv) \
		$(use_enable xinerama video-x11-xinerama) \
		$(use_enable X video-x11-xrandr) \
		$(use_enable dga video-dga) \
		$(use_enable fbcon video-fbcon) \
		$(use_enable ggi video-ggi) \
		$(use_enable svga video-svga) \
		$(use_enable aalib video-aalib) \
		$(use_enable libcaca video-caca) \
		$(use_enable opengl video-opengl) \
		$(use_enable ps3 video-ps3) \
		$(use_enable tslib input-tslib) \
		$(use_with X x) \
		$(use_enable static-libs static) \
		--disable-video-x11-xme \
		${myconf}
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	use static-libs || rm -f "${ED}"/usr/$(get_libdir)/lib*.la
	dodoc BUGS CREDITS README README-SDL.txt README.HG TODO WhatsNew
	dohtml -r ./
}
