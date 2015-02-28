# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/geoip/geoip-1.6.0-r1.ebuild,v 1.18 2014/09/04 01:10:13 blueness Exp $

EAPI=5
inherit autotools eutils

GEOLITE_URI="https://geolite.maxmind.com/download/geoip/database/"

DESCRIPTION="easily lookup countries by IP addresses, even when Reverse DNS entries don't exist"
HOMEPAGE="https://github.com/maxmind/geoip-api-c"
SRC_URI="
	https://github.com/maxmind/${PN}-api-c/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${GEOLITE_URI}GeoLiteCountry/GeoIP.dat.gz
	${GEOLITE_URI}asnum/GeoIPASNum.dat.gz
	city? ( ${GEOLITE_URI}GeoLiteCity.dat.gz )
	ipv6? (
		${GEOLITE_URI}GeoIPv6.dat.gz
		city? ( ${GEOLITE_URI}GeoLiteCityv6-beta/GeoLiteCityv6.dat.gz )
	)
"

# GPL-2 for md5.c - part of libGeoIPUpdate, MaxMind for GeoLite Country db
LICENSE="LGPL-2.1 GPL-2 MaxMind2"
SLOT="0"
KEYWORDS="alpha amd64 arm arm64 hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE="city ipv6 static-libs"

DEPEND="sys-libs/zlib"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-api-c-${PV}"

src_prepare() {
	sed -e 's|yahoo.com|98.139.183.24|g' \
		-i test/country_test_name.txt test/region_test.txt || die

	# used in src_test() (bug #494650):
	mkdir data/ || die
	cp "${WORKDIR}"/GeoIP.dat data/ || die

	eautoreconf
}

src_configure() {
	econf $(use_enable static-libs static)
}

src_install() {
	default

	dodoc AUTHORS ChangeLog README* TODO

	prune_libtool_files

	insinto /usr/share/GeoIP
	doins "${WORKDIR}"/{GeoIP,GeoIPASNum}.dat
	use city && newins "${WORKDIR}"/GeoLiteCity.dat GeoIPCity.dat

	if use ipv6; then
		doins "${WORKDIR}/GeoIPv6.dat"
		use city && newins "${WORKDIR}"/GeoLiteCityv6.dat GeoIPCityv6.dat
	fi

	newsbin "${FILESDIR}/geoipupdate-r2.sh" geoipupdate.sh
}
