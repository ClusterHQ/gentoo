# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/spice/spice-0.12.2.ebuild,v 1.6 2014/08/06 06:44:37 patrick Exp $

EAPI=5

PYTHON_DEPEND="2"

inherit eutils python

DESCRIPTION="SPICE server and client"
HOMEPAGE="http://spice-space.org/"
SRC_URI="http://spice-space.org/download/releases/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+client +gui sasl smartcard static-libs" # static

RDEPEND=">=x11-libs/pixman-0.17.7
	media-libs/alsa-lib
	media-libs/celt:0.5.1
	dev-libs/openssl
	virtual/jpeg
	sys-libs/zlib
	sasl? ( dev-libs/cyrus-sasl )
	smartcard? ( >=app-emulation/libcacard-0.1.2 )
	client? (
		gui? ( =dev-games/cegui-0.6*[opengl] )
		>=x11-libs/libXrandr-1.2
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXinerama
		x11-libs/libXfixes
		x11-libs/libXrender
	)"

# broken as we don't have static alsa-lib and building that one static requires more work
#		static? (
#			>=x11-libs/pixman-0.17.7[static-libs(+)]
#			media-libs/celt:0.5.1[static-libs(+)]
#			virtual/jpeg[static-libs(+)]
#			sys-libs/zlib[static-libs(+)]
#			media-libs/alsa-lib[static-libs(-)]
#			>=x11-libs/libXrandr-1.2[static-libs(+)]
#			x11-libs/libX11[static-libs(+)]
#			x11-libs/libXext[static-libs(+)]
#			x11-libs/libXinerama[static-libs(+)]
#			x11-libs/libXfixes[static-libs(+)]
#			x11-libs/libXrender[static-libs(+)]
#		)
#	)"
DEPEND="virtual/pkgconfig
	dev-python/pyparsing
	${RDEPEND}"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

# maintainer notes:
# * opengl support is currently broken
# * TODO: add slirp for tunnel-support

src_prepare() {
	epatch \
		"${FILESDIR}/0.11.0-gold.patch"
}

src_configure() {
	python_convert_shebangs 2 spice-common/spice_codegen.py

	econf \
		$(use_enable static-libs static) \
		--disable-tunnel \
		$(use_enable client) \
		$(use_enable gui) \
		$(use_with sasl) \
		$(use_enable smartcard) \
		--disable-static-linkage
#		$(use_enable static static-linkage) \
}

src_install() {
	default
	use static-libs || rm "${D}"/usr/lib*/*.la
}
