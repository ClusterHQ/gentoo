# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/geoipupdate/geoipupdate-2.0.2.ebuild,v 1.1 2014/07/23 08:39:28 jer Exp $

EAPI=5

DESCRIPTION="performs automatic updates of GeoIP2 and GeoIP Legacy binary databases"
HOMEPAGE="https://github.com/maxmind/geoipupdate"
SRC_URI="https://github.com/maxmind/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~x86 ~x86-fbsd"
IUSE=""

DEPEND="
	net-misc/curl
	sys-libs/zlib
"
RDEPEND="
	${DEPEND}
	!<dev-libs/geoip-1.6.0
"

src_install() {
	default
	keepdir /usr/share/GeoIP
}
