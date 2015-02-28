# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/pmacct/pmacct-1.5.0_rc3.ebuild,v 1.3 2014/08/06 19:52:46 jer Exp $

EAPI=5
inherit autotools eutils toolchain-funcs

DESCRIPTION="A network tool to gather IP traffic information"
HOMEPAGE="http://www.pmacct.net/"
SRC_URI="http://www.pmacct.net/${P/_}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="64bit debug geoip ipv6 mongodb mysql postgres sqlite threads ulog"

RDEPEND="
	net-libs/libpcap
	geoip? ( dev-libs/geoip )
	mongodb? ( >=dev-libs/mongo-c-driver-0.8.1-r1 )
	mysql? ( virtual/mysql )
	postgres? ( dev-db/postgresql-base )
	sqlite? ( =dev-db/sqlite-3* )
"
DEPEND="
	${RDEPEND}
	virtual/pkgconfig
"

S="${WORKDIR}/${P/_/}"

DOCS=(
	CONFIG-KEYS ChangeLog FAQS KNOWN-BUGS QUICKSTART README TODO TOOLS UPGRADE
	docs/INTERNALS docs/PLUGINS docs/SIGNALS
)

src_prepare() {
	epatch "${FILESDIR}"/${P}-mongodb.patch
	eautoreconf
}

src_configure() {
	tc-export CC AR RANLIB

	econf \
		$(use_enable 64bit) \
		$(use_enable debug) \
		$(use_enable geoip) \
		$(use_enable ipv6) \
		$(use_enable mongodb) \
		$(use_enable mysql) \
		$(use_enable postgres pgsql) \
		$(use_enable sqlite sqlite3) \
		$(use_enable threads) \
		$(use_enable ulog) \
		--disable-debug
}

src_install() {
	default

	for dirname in examples sql; do
		docinto ${dirname}
		dodoc -r ${dirname}/*
	done

	newinitd "${FILESDIR}"/pmacctd-init.d pmacctd
	newconfd "${FILESDIR}"/pmacctd-conf.d pmacctd

	insinto /etc/pmacctd
	newins examples/pmacctd-imt.conf.example pmacctd.conf
}
