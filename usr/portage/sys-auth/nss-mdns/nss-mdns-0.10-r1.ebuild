# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-auth/nss-mdns/nss-mdns-0.10-r1.ebuild,v 1.4 2012/08/15 11:54:25 blueness Exp $

EAPI="4"
inherit autotools eutils

DESCRIPTION="Name Service Switch module for Multicast DNS"
HOMEPAGE="http://0pointer.de/lennart/projects/nss-mdns/"
SRC_URI="http://0pointer.de/lennart/projects/nss-mdns/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~hppa ~mips ppc x86"
IUSE="search-domains"

DEPEND="net-dns/avahi"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-0.10-avahi-socket.patch
	eautoreconf
}

src_configure() {
	econf $(use_enable search-domains) --enable-avahi
}

src_install() {
	emake DESTDIR="${D}" install

	insinto /etc
	doins "${FILESDIR}"/mdns.allow
	dodoc README
}

pkg_postinst() {
	ewarn
	ewarn "You must modify your name service switch look up file to enable"
	ewarn "multicast DNS lookups.  If you wish to resolve only IPv6 addresses"
	ewarn "use mdns6.  For IPv4 addresses only, use mdns4.  To resolve both"
	ewarn "use mdns.  Keep in mind that mdns will be slower if there are no"
	ewarn "IPv6 addresses published via mDNS on the network.  There are also"
	ewarn "minimal (mdns?_minimal) libraries which only lookup .local hosts"
	ewarn "and 169.254.x.x addresses."
	ewarn
	ewarn "Add the appropriate mdns into the hosts line in /etc/nsswitch.conf"
	ewarn "An example line looks like:"
	ewarn "hosts:	files mdns4_minimal [NOTFOUND=return] dns mdns4"
	ewarn
	ewarn "If you want to perform mDNS lookups for domains other than the ones"
	ewarn "ending in .local, add them to /etc/mdns.allow"
	ewarn
}
