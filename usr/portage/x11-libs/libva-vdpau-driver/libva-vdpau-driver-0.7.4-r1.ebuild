# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libva-vdpau-driver/libva-vdpau-driver-0.7.4-r1.ebuild,v 1.5 2014/07/24 15:30:56 ssuominen Exp $

EAPI=5

AUTOTOOLS_AUTORECONF="yes"
inherit autotools-multilib eutils

DESCRIPTION="VDPAU Backend for Video Acceleration (VA) API"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/vaapi"
SRC_URI="http://www.freedesktop.org/software/vaapi/releases/libva-vdpau-driver/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="debug opengl"

RDEPEND=">=x11-libs/libva-1.2.1-r1[X,opengl?,${MULTILIB_USEDEP}]
	opengl? ( >=virtual/opengl-7.0-r1[${MULTILIB_USEDEP}] )
	=x11-libs/libvdpau-0.7*[${MULTILIB_USEDEP}]
	!x11-libs/vdpau-video"

DEPEND="${DEPEND}
	virtual/pkgconfig"

DOCS=( NEWS README AUTHORS )

src_prepare() {
	epatch "${FILESDIR}/${P}-glext-missing-definition.patch"
	epatch "${FILESDIR}/${P}-VAEncH264VUIBufferType.patch"
	sed -i 's/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/g' configure.ac || die
	autotools-multilib_src_prepare
}

multilib_src_configure() {
	local myeconfargs=(
		$(use_enable debug)
		$(use_enable opengl glx)
	)
	autotools-utils_src_configure
}
