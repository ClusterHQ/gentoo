# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/jack-audio-connection-kit/jack-audio-connection-kit-0.121.3.ebuild,v 1.16 2013/05/13 03:40:20 blueness Exp $

EAPI=2

inherit flag-o-matic eutils multilib

DESCRIPTION="A low-latency audio server"
HOMEPAGE="http://www.jackaudio.org"
SRC_URI="http://www.jackaudio.org/downloads/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~ppc-macos"
IUSE="3dnow altivec alsa coreaudio doc debug examples mmx oss sse cpudetection pam"

RDEPEND=">=media-libs/libsndfile-1.0.0
	sys-libs/ncurses
	caps? ( sys-libs/libcap )
	alsa? ( >=media-libs/alsa-lib-1.0.18 )
	media-libs/libsamplerate
	!media-sound/jack-cvs"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( app-doc/doxygen )"
RDEPEND="${RDEPEND}
	alsa? ( sys-process/lsof )
	pam? ( sys-auth/realtime-base )"

src_prepare() {
	epatch "${FILESDIR}/${PN}-sparc-cpuinfo.patch"
	epatch "${FILESDIR}/${PN}-freebsd.patch"
}

src_configure() {
	local myconf=""

	# CPU Detection (dynsimd) uses asm routines which requires 3dnow, mmx and sse.
	if use cpudetection && use 3dnow && use mmx && use sse ; then
		einfo "Enabling cpudetection (dynsimd). Adding -mmmx, -msse, -m3dnow and -O2 to CFLAGS."
		myconf="${myconf} --enable-dynsimd"
		append-flags -mmmx -msse -m3dnow -O2
	fi

	use doc || export ac_cv_prog_HAVE_DOXYGEN=false

	econf \
		$(use_enable altivec) \
		$(use_enable alsa) \
		$(use_enable coreaudio) \
		$(use_enable debug) \
		$(use_enable mmx) \
		$(use_enable oss) \
		--disable-portaudio \
		$(use_enable sse) \
		--with-html-dir="${EPREFIX}"/usr/share/doc/${PF} \
		--disable-dependency-tracking \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		${myconf} || die "configure failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS TODO README

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r "${S}/example-clients"
	fi
}
