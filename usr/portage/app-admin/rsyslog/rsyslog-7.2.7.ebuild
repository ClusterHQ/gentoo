# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/rsyslog/rsyslog-7.2.7.ebuild,v 1.10 2014/04/16 16:14:41 maksbotan Exp $

EAPI=4
AUTOTOOLS_AUTORECONF=yes

inherit autotools-utils eutils systemd

DESCRIPTION="An enhanced multi-threaded syslogd with database support and more"
HOMEPAGE="http://www.rsyslog.com/"
SRC_URI="http://www.rsyslog.com/files/download/${PN}/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3 Apache-2.0"
KEYWORDS="amd64 ~arm hppa x86"
SLOT="0"
IUSE="dbi debug doc extras kerberos mysql oracle postgres relp snmp ssl static-libs zeromq zlib"

RDEPEND="
	dev-libs/json-c
	dev-libs/libee
	>=dev-libs/libestr-0.1.5
	dev-libs/libgcrypt:0
	dev-libs/liblognorm
	dbi? ( dev-db/libdbi )
	extras? ( net-libs/libnet )
	kerberos? ( virtual/krb5 )
	mysql? ( virtual/mysql )
	postgres? ( dev-db/postgresql-base )
	oracle? ( dev-db/oracle-instantclient-basic )
	relp? ( >=dev-libs/librelp-1.0.1 )
	snmp? ( net-analyzer/net-snmp )
	ssl? ( net-libs/gnutls )
	zeromq? ( >=net-libs/zeromq-3 <net-libs/czmq-2 )
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

BRANCH="7-stable"

# need access to certain device nodes
RESTRICT="test"

# Maitainer note : open a bug to upstream
# showing that building in a separate dir fails
AUTOTOOLS_IN_SOURCE_BUILD=1

DOCS=(AUTHORS ChangeLog doc/rsyslog-example.conf)

PATCHES=(
	"${FILESDIR}"/${PN}-7.2.5-json-c-pkgconfig.patch

	# Fix runtime UUID/JSON libs linking
	"${FILESDIR}"/6-stable/${PN}-6.6.0-fix-runtime.patch

	# Fix for #507730
	"$FILESDIR"/${BRANCH}/${PN}-7.x-mmjsonparse.patch
)

src_prepare() {
	# Don't force '-g' CFLAG
	sed -e 's/CFLAGS="\(.*\) -g"/CFLAGS="\1"/g' -i configure.ac || die

	autotools-utils_src_prepare
}

src_configure() {
	# Maintainer notes:
	# * rfc3195 needs a library and development of that library
	#   is suspended, so we disable it
	# * About the java GUI:
	#   The maintainer says there is no real installation support
	#   for the java GUI, so we disable it for now.
	# * mongodb : doesnt work with mongo-c-driver ?
	local myeconfargs=(
		--disable-gui
		--disable-rfc3195
		--enable-imdiag
		--enable-imfile
		--enable-impstats
		--enable-imptcp
		--enable-largefile
		--enable-mail
		--enable-mmnormalize
		--enable-mmjsonparse
		--enable-mmaudit
		--enable-omprog
		--enable-omstdout
		--enable-omuxsock
		--enable-pmlastmsg
		--enable-pmrfc3164sd
		--enable-pmcisconames
		--enable-pmaixforwardedfrom
		--enable-pmsnare
		--enable-sm_cust_bindcdr
		--enable-unlimited-select
		--enable-uuid
		$(use_enable dbi libdbi)
		$(use_enable debug)
		$(use_enable debug rtinst)
		$(use_enable debug diagtools)
		$(use_enable debug memcheck)
		$(use_enable debug valgrind)
		$(use_enable extras omudpspoof)
		$(use_enable kerberos gssapi-krb5)
		$(use_enable mysql)
		$(use_enable oracle)
		$(use_enable postgres pgsql)
		$(use_enable relp)
		$(use_enable snmp)
		$(use_enable snmp mmsnmptrapd)
		$(use_enable ssl gnutls)
		$(use_enable zlib)
		$(use_enable zeromq imzmq3)
		$(use_enable zeromq omzmq3)
		"$(systemd_with_unitdir)"
	)
	autotools-utils_src_configure
}

src_install() {
	use doc && HTML_DOCS=(doc/)
	autotools-utils_src_install

	insinto /etc
	newins "${FILESDIR}/${BRANCH}/${PN}-gentoo.conf" ${PN}.conf
	newconfd "${FILESDIR}/${BRANCH}/${PN}.confd" ${PN}
	newinitd "${FILESDIR}/${BRANCH}/${PN}.initd" ${PN}
	keepdir /var/spool/${PN}
	keepdir /etc/ssl/${PN}
	keepdir /etc/${PN}.d

	use static-libs || find "${D}" -name '*.la' -delete || die

	if use mysql; then
		insinto /usr/share/doc/${PF}/scripts/mysql
		doins plugins/ommysql/{createDB.sql,contrib/delete_mysql}
	fi

	if use postgres; then
		insinto /usr/share/doc/${PF}/scripts/pgsql
		doins plugins/ompgsql/createDB.sql
	fi

	insinto /etc/logrotate.d/
	newins "${FILESDIR}/${BRANCH}/${PN}.logrotate" ${PN}
}

pkg_postinst() {
	if use mysql || use postgres; then
		echo
		elog "Sample SQL scripts for MySQL & PostgreSQL have been installed to:"
		elog "  /usr/share/doc/${PF}/scripts"
	fi

	if use ssl; then
		echo
		elog "To create a default CA and certificates for your server and clients, run:"
		elog "  emerge --config =${PF}"
		elog "on your logging server. You can run it several times,"
		elog "once for each logging client. The client certificates will be signed"
		elog "using the CA certificate generated during the first run."
	fi
}

pkg_config() {
	if ! use ssl ; then
		einfo "There is nothing to configure for rsyslog unless you"
		einfo "used USE=ssl to build it."
		return 0
	fi

	# Make sure the certificates directory exists
	CERTDIR="${ROOT}/etc/ssl/${PN}"
	if [ ! -d "${CERTDIR}" ]; then
		mkdir "${CERTDIR}" || die
	fi
	einfo "Your certificates will be stored in ${CERTDIR}"

	# Create a default CA if needed
	if [ ! -f "${CERTDIR}/${PN}_ca.cert.pem" ]; then
		einfo "No CA key and certificate found in ${CERTDIR}, creating them for you..."
		certtool --generate-privkey \
			--outfile "${CERTDIR}/${PN}_ca.privkey.pem" &>/dev/null
		chmod 400 "${CERTDIR}/${PN}_ca.privkey.pem"

		cat > "${T}/${PF}.$$" <<- _EOF
		cn = Portage automated CA
		ca
		cert_signing_key
		expiration_days = 3650
		_EOF

		certtool --generate-self-signed \
			--load-privkey "${CERTDIR}/${PN}_ca.privkey.pem" \
			--outfile "${CERTDIR}/${PN}_ca.cert.pem" \
			--template "${T}/${PF}.$$" &>/dev/null
		chmod 400 "${CERTDIR}/${PN}_ca.privkey.pem"

		# Create the server certificate
		echo
		einfon "Please type the Common Name of the SERVER you wish to create a certificate for: "
		read -r CN

		einfo "Creating private key and certificate for server ${CN}..."
		certtool --generate-privkey \
			--outfile "${CERTDIR}/${PN}_${CN}.key.pem" &>/dev/null
		chmod 400 "${CERTDIR}/${PN}_${CN}.key.pem"

		cat > "${T}/${PF}.$$" <<- _EOF
		cn = ${CN}
		tls_www_server
		dns_name = ${CN}
		expiration_days = 3650
		_EOF

		certtool --generate-certificate \
			--outfile "${CERTDIR}/${PN}_${CN}.cert.pem" \
			--load-privkey "${CERTDIR}/${PN}_${CN}.key.pem" \
			--load-ca-certificate "${CERTDIR}/${PN}_ca.cert.pem" \
			--load-ca-privkey "${CERTDIR}/${PN}_ca.privkey.pem" \
			--template "${T}/${PF}.$$" &>/dev/null
		chmod 400 "${CERTDIR}/${PN}_${CN}.cert.pem"

	else
		einfo "Found existing ${CERTDIR}/${PN}_ca.cert.pem, skipping CA and SERVER creation."
	fi

	# Create a client certificate
	echo
	einfon "Please type the Common Name of the CLIENT you wish to create a certificate for: "
	read -r CN

	einfo "Creating private key and certificate for client ${CN}..."
	certtool --generate-privkey \
		--outfile "${CERTDIR}/${PN}_${CN}.key.pem" &>/dev/null
	chmod 400 "${CERTDIR}/${PN}_${CN}.key.pem"

	cat > "${T}/${PF}.$$" <<- _EOF
	cn = ${CN}
	tls_www_client
	dns_name = ${CN}
	expiration_days = 3650
	_EOF

	certtool --generate-certificate \
		--outfile "${CERTDIR}/${PN}_${CN}.cert.pem" \
		--load-privkey "${CERTDIR}/${PN}_${CN}.key.pem" \
		--load-ca-certificate "${CERTDIR}/${PN}_ca.cert.pem" \
		--load-ca-privkey "${CERTDIR}/${PN}_ca.privkey.pem" \
		--template "${T}/${PF}.$$" &>/dev/null
	chmod 400 "${CERTDIR}/${PN}_${CN}.cert.pem"

	rm -f "${T}/${PF}.$$"

	echo
	einfo "Here is the documentation on how to encrypt your log traffic:"
	einfo " http://www.rsyslog.com/doc/rsyslog_tls.html"
}
