# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-apache/mod_auth_openid/mod_auth_openid-0.8.ebuild,v 1.1 2014/05/26 05:27:45 polynomial-c Exp $

EAPI=5

inherit apache-module

DESCRIPTION="An OpenID authentication module for the apache webserver"
HOMEPAGE="http://findingscience.com/mod_auth_openid/"
SRC_URI="https://github.com/bmuller/mod_auth_openid/releases/download/v${PV}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-db/sqlite-3
	dev-libs/libpcre
	>=net-libs/libopkele-2.0
	net-misc/curl"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

APACHE2_MOD_CONF="10_${PN}"
APACHE2_MOD_DEFINE="AUTH_OPENID"

need_apache2_2

src_configure() {
	econf --with-apxs="${APXS}" \
		--with-sqlite3=/usr \
		--with-apr-config=/usr/bin/apr-1-config
}

src_compile() {
	# default src_compile fails
	emake
}
