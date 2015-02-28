# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils-config/binutils-config-3-r3.ebuild,v 1.9 2012/07/29 18:36:13 armin76 Exp $

EAPI=3

inherit eutils toolchain-funcs prefix

DESCRIPTION="Utility to change the binutils version being used - prefix version"
HOMEPAGE="http://www.gentoo.org/"
W_VER="0.3.1723"
SRC_URI="http://dev.gentoo.org/~grobian/distfiles/toolchain-prefix-wrapper-${W_VER}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="sunld"

RDEPEND="userland_GNU? ( !<sys-apps/findutils-4.2 )"

S=${WORKDIR}/toolchain-prefix-wrapper-${W_VER}

src_prepare() {
	cp "${FILESDIR}"/${P} ./${PN} || die
	eprefixify ${PN} || die "eprefixify failed."
}

src_configure() {
	econf --with-macosx-version-min=${MACOSX_DEPLOYMENT_TARGET} \
		$(use_with sunld native-ld)
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed."
	dobin ${PN} || die "cannot install ${PN} script."
}

pkg_postinst() {
	# refresh all links and the wrapper
	if [[ ${ROOT%/} == "" ]] ; then
		[[ -f ${EROOT}/etc/env.d/binutils/config-${CHOST} ]] \
			&& binutils-config $(${EROOT}/usr/bin/binutils-config --get-current-profile)
	fi
}
