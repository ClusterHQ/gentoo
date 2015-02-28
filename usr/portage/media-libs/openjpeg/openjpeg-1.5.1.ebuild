# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/openjpeg/openjpeg-1.5.1.ebuild,v 1.13 2013/08/06 13:12:13 ago Exp $

EAPI=5
inherit cmake-utils multilib

DESCRIPTION="An open-source JPEG 2000 library"
HOMEPAGE="http://code.google.com/p/openjpeg/"
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 ~sh sparc x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc static-libs test"

RDEPEND="media-libs/lcms:2=[static-libs?]
	media-libs/libpng:0=[static-libs?]
	media-libs/tiff:0=[static-libs?]
	sys-libs/zlib:=[static-libs?]"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

DOCS=( AUTHORS CHANGES NEWS README THANKS )

PATCHES=( "${FILESDIR}"/${P}-build.patch )

RESTRICT="test" #409263

src_configure() {
	local mycmakeargs=(
		-DOPENJPEG_INSTALL_LIB_DIR="$(get_libdir)"
		$(cmake-utils_use_build doc)
		$(cmake-utils_use_build test TESTING)
		)

	cmake-utils_src_configure

	if use static-libs ; then
		mycmakeargs=(
			-DOPENJPEG_INSTALL_LIB_DIR="$(get_libdir)"
			$(cmake-utils_use_build test TESTING)
			-DBUILD_SHARED_LIBS=OFF
			)
		BUILD_DIR=${BUILD_DIR}_static cmake-utils_src_configure
	fi
}

src_compile() {
	cmake-utils_src_compile

	if use static-libs ; then
		BUILD_DIR=${BUILD_DIR}_static cmake-utils_src_compile
	fi
}

src_install() {
	if use static-libs ; then
		BUILD_DIR=${BUILD_DIR}_static cmake-utils_src_install
		#static bins overwritten by shared install
	fi

	cmake-utils_src_install

	dosym openjpeg-1.5/openjpeg.h /usr/include/openjpeg.h
	dosym libopenjpeg1.pc /usr/$(get_libdir)/pkgconfig/libopenjpeg.pc
}
