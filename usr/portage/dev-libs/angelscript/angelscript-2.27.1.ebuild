# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/angelscript/angelscript-2.27.1.ebuild,v 1.4 2014/04/28 17:23:53 mgorny Exp $

EAPI=5

inherit toolchain-funcs multilib-minimal

DESCRIPTION="A flexible, cross-platform scripting library"
HOMEPAGE="http://www.angelcode.com/angelscript/"
SRC_URI="http://www.angelcode.com/angelscript/sdk/files/angelscript_${PV}.zip"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc static-libs"

DEPEND="app-arch/unzip"

S=${WORKDIR}/sdk
S2=${WORKDIR}/sdk_static

pkg_setup() {
	tc-export CXX AR RANLIB
}

src_prepare() {
	if use static-libs ; then
		cp -pR "${WORKDIR}"/sdk "${S2}"/ || die
	fi
	multilib_copy_sources
}

multilib_src_compile() {
	einfo "Shared build"
	emake -C ${PN}/projects/gnuc SHARED=1 VERSION=${PV}

	if multilib_is_native_abi ; then
		if use static-libs ; then
			einfo "Static build"
			emake -C "${S2}"/${PN}/projects/gnuc
		fi
	fi
}

multilib_src_install() {
	doheader ${PN}/include/angelscript.h
	dolib.so ${PN}/lib/libangelscript-${PV}.so
	dosym libangelscript-${PV}.so /usr/$(get_libdir)/libangelscript.so

	if multilib_is_native_abi ; then
		if use static-libs ; then
			 dolib.a "${S2}"/${PN}/lib/libangelscript.a
		fi
	fi
}

multilib_src_install_all() {
	use doc && dohtml -r "${WORKDIR}"/sdk/docs/*
}
