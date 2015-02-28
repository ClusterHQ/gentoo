# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/install-xattr/install-xattr-0.3.ebuild,v 1.9 2014/08/30 17:10:23 blueness Exp $

EAPI=5
DESCRIPTION="Wrapper to coreutil's install to preserve Filesystem Extended Attributes"
HOMEPAGE="http://dev.gentoo.org/~blueness/install-xattr/"

inherit toolchain-funcs

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="git://git.overlays.gentoo.org/proj/elfix.git"
	KEYWORDS="alpha hppa ia64 ~sh sparc"
	inherit git-2
else
	SRC_URI="http://dev.gentoo.org/~blueness/install-xattr/${P}.tar.bz2"
	KEYWORDS="alpha amd64 arm arm64 hppa ia64 ~mips ppc ppc64 ~s390 ~sh sparc x86"
	S=${WORKDIR}/${PN}
fi

LICENSE="GPL-3"
SLOT="0"

src_prepare() {
	tc-export CC
}

src_compile() {
	if [[ ${PV} == "9999" ]] ; then
		cd "${WORKDIR}/${P}/misc/${PN}"
	fi
	default
}

src_install() {
	if [[ ${PV} == "9999" ]] ; then
		cd "${WORKDIR}/${P}/misc/${PN}"
	fi
	default
}

# We need to fix how tests are done
src_test() {
	true
}
