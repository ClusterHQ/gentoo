# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/jack-audio-connection-kit/jack-audio-connection-kit-0.121.3-r1.ebuild,v 1.5 2014/07/23 15:23:03 ago Exp $

EAPI=5

inherit flag-o-matic eutils multilib multilib-minimal

DESCRIPTION="A low-latency audio server"
HOMEPAGE="http://www.jackaudio.org"
SRC_URI="http://www.jackaudio.org/downloads/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~ppc-macos"
IUSE="3dnow altivec alsa coreaudio doc debug examples mmx oss sse cpudetection pam"

# readline: only used for jack_transport -> useless for non native ABIs
# libsndfile: ditto for jackrec
RDEPEND="
	sys-libs/readline
	>=media-libs/libsndfile-1.0.0
	alsa? ( >=media-libs/alsa-lib-1.0.27.2[${MULTILIB_USEDEP}] )
	>=media-libs/libsamplerate-0.1.8-r1[${MULTILIB_USEDEP}]
	!media-sound/jack-cvs
	abi_x86_32? ( !<=app-emulation/emul-linux-x86-soundlibs-20130224-r7
					!app-emulation/emul-linux-x86-soundlibs[-abi_x86_32(-)] )"
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

DOCS=( AUTHORS TODO README )

multilib_src_configure() {
	local myconf=""

	# CPU Detection (dynsimd) uses asm routines which requires 3dnow, mmx and sse.
	if use cpudetection && use 3dnow && use mmx && use sse ; then
		einfo "Enabling cpudetection (dynsimd). Adding -mmmx, -msse, -m3dnow and -O2 to CFLAGS."
		myconf="${myconf} --enable-dynsimd"
		append-flags -mmmx -msse -m3dnow -O2
	fi

	use doc || export ac_cv_prog_HAVE_DOXYGEN=false

	ECONF_SOURCE="${S}" econf \
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
		${myconf}

	if [ "${ABI}" != "${DEFAULT_ABI}" ] ; then
		for i in tools man ; do
			sed -i -e "s/ ${i}//" Makefile || die
		done
	fi
}

multilib_src_install_all() {
	einstalldocs
	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r "${S}/example-clients"
		docompress -x /usr/share/doc/${PF}/example-clients
	fi
}
