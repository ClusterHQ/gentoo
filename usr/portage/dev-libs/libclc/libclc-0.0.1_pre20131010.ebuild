# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libclc/libclc-0.0.1_pre20131010.ebuild,v 1.3 2014/04/06 10:10:38 ago Exp $

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7} )

EGIT_REPO_URI="http://llvm.org/git/${PN}.git"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-2"
	EXPERIMENTAL="true"
fi

inherit base python-any-r1 $GIT_ECLASS

DESCRIPTION="OpenCL C library"
HOMEPAGE="http://libclc.llvm.org/"

if [[ $PV = 9999* ]]; then
	SRC_URI="${SRC_PATCHES}"
else
	SRC_URI="mirror://gentoo/${P}.tar.xz ${SRC_PATCHES}"
fi

LICENSE="|| ( MIT BSD )"
SLOT="0"
KEYWORDS="amd64 ~ppc x86"
IUSE=""

RDEPEND="
	>=sys-devel/clang-3.2
	>=sys-devel/llvm-3.2"
DEPEND="${RDEPEND}"

src_unpack() {
	if [[ $PV = 9999* ]]; then
		git-2_src_unpack
	else
		default
		mv ${PN}-*/ ${P} || die
	fi
}

src_configure() {
	./configure.py \
		--with-llvm-config="${EPREFIX}/usr/bin/llvm-config" \
		--prefix="${EPREFIX}/usr" \
		--pkgconfigdir="${EPREFIX}/usr/share/pkgconfig" || die
}

src_compile() {
	emake VERBOSE=1
}
