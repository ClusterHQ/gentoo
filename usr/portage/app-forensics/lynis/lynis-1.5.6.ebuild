# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-forensics/lynis/lynis-1.5.6.ebuild,v 1.1 2014/07/06 11:13:40 idl0r Exp $

EAPI="5"

inherit eutils

DESCRIPTION="Security and system auditing tool"
HOMEPAGE="http://cisofy.com/lynis/"
SRC_URI="http://cisofy.com/files/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="app-shells/bash"

src_prepare() {
	# Bug 507438
	epatch_user
}

src_install() {
	doman lynis.8
	dodoc CHANGELOG FAQ README dev/TODO

	# Remove the old one during the next stabilize progress
	exeinto /etc/cron.daily
	newexe "${FILESDIR}"/lynis.cron-new lynis

	# stricter default perms - bug 507436
	diropts -m0750
	insopts -m0640

	insinto /usr/share/${PN}
	doins -r db/ include/ plugins/

	dosbin lynis

	insinto /etc/${PN}
	doins default.prf
}

pkg_postinst() {
	einfo
	einfo "A cron script has been installed to ${ROOT}etc/cron.daily/lynis."
	einfo
}
