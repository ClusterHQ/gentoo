# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/isatapd/isatapd-0.9.7-r1.ebuild,v 1.1 2014/03/30 10:09:14 pacho Exp $

EAPI=5
inherit linux-info systemd

DESCRIPTION="creates and maintains an ISATAP tunnel (rfc5214)"
HOMEPAGE="http://www.saschahlusiak.de/linux/isatap.htm"
SRC_URI="http://www.saschahlusiak.de/linux/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=""

CONFIG_CHECK="~TUN"
ERROR_TUN="CONFIG_TUN is needed for isatapd to work"

src_prepare() {
	sed -e '/^opts/s:opts:extra_started_commands:' \
		-i openrc/isatapd.init.d || die
}

src_install() {
	default

	newinitd openrc/isatapd.init.d isatapd
	newconfd openrc/isatapd.conf.d isatapd
	systemd_newunit "${FILESDIR}"/${PN}.service-r1 ${PN}.service
	systemd_install_serviced "${FILESDIR}"/${PN}.service.conf
}
