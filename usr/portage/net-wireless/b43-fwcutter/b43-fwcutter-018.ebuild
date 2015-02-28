# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/b43-fwcutter/b43-fwcutter-018.ebuild,v 1.5 2014/01/19 10:26:33 ago Exp $

inherit toolchain-funcs

DESCRIPTION="Firmware Tool for Broadcom 43xx based wireless network devices
using the mac80211 wireless stack"
HOMEPAGE="http://bues.ch/b43/fwcutter"
SRC_URI="http://bues.ch/b43/fwcutter/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc ppc64 x86"

IUSE=""
DEPEND=""
RDEPEND=""

src_compile() {
	MAKEOPTS+=" V=1"
	emake CC="$(tc-getCC)" || die "emake failed"
}

src_install() {
	# Install fwcutter
	exeinto /usr/bin
	doexe ${PN}
	doman ${PN}.1
	dodoc README
}

pkg_postinst() {
	einfo
	einfo "Firmware may be downloaded from http://linuxwireless.org."
	einfo "This version of fwcutter works with all b43 driver versions."
	einfo
}
