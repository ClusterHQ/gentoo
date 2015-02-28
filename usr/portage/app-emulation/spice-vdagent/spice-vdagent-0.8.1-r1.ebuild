# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/spice-vdagent/spice-vdagent-0.8.1-r1.ebuild,v 1.5 2014/08/06 06:44:37 patrick Exp $

EAPI=4

inherit linux-info

DESCRIPTION="SPICE VD Linux Guest Agent"
HOMEPAGE="http://spice-space.org/"
SRC_URI="http://spice-space.org/download/releases/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+consolekit selinux"

RDEPEND="x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libX11
	>=app-emulation/spice-protocol-0.8.1
	consolekit? ( sys-auth/consolekit sys-apps/dbus )
	selinux? ( sec-policy/selinux-vdagent )"
DEPEND="virtual/pkgconfig
	${RDEPEND}"

CONFIG_CHECK="~INPUT_UINPUT"
ERROR_INPUT_UINPUT="User level driver support is required to run the spice-vdagent daemon"

src_configure() {
	econf \
		--localstatedir=/var \
		$(use_enable consolekit console-kit)
}

src_install() {
	default

	rm -rf "${D}"/etc/{rc,tmpfiles}.d

	keepdir /var/run/spice-vdagentd
	keepdir /var/log/spice-vdagentd

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
}

pkg_postinst() {
	elog "Make sure that the User level driver support kernel module 'uinput' is loaded"
	elog "if built as a module before starting the vdagent daemon."
}
