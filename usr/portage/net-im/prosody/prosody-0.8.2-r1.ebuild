# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-im/prosody/prosody-0.8.2-r1.ebuild,v 1.6 2014/08/05 18:34:13 mrueg Exp $

EAPI="5"

inherit eutils multilib systemd toolchain-funcs versionator

MY_PV=$(replace_version_separator 3 '')
DESCRIPTION="Prosody is a flexible communications server for Jabber/XMPP written in Lua"
HOMEPAGE="http://prosody.im/"
SRC_URI="http://prosody.im/downloads/source/${PN}-${MY_PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm x86"
IUSE="libevent mysql postgres sqlite ssl zlib"

DEPEND="net-im/jabber-base
		>=dev-lang/lua-5.1
		>=net-dns/libidn-1.1
		>=dev-libs/openssl-0.9.8"
RDEPEND="${DEPEND}
		dev-lua/luasocket
		ssl? ( dev-lua/luasec )
		dev-lua/luaexpat
		dev-lua/luafilesystem
		mysql? ( >=dev-lua/luadbi-0.5[mysql] )
		postgres? ( >=dev-lua/luadbi-0.5[postgres] )
		sqlite? ( >=dev-lua/luadbi-0.5[sqlite] )
		libevent? ( dev-lua/luaevent )
		zlib? ( dev-lua/lua-zlib )"

S="${WORKDIR}/${PN}-${MY_PV}"

JABBER_ETC="/etc/jabber"
JABBER_SPOOL="/var/spool/jabber"

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.8.0-cfg.lua.patch"

	# Modify config to let prosodyctl work by default
	sed -i -e 's/--"posix"/"posix"/' prosody.cfg.lua.dist || die

	sed -i "s!MODULES = \$(DESTDIR)\$(PREFIX)/lib/!MODULES = \$(DESTDIR)\$(PREFIX)/$(get_libdir)/!" Makefile
	sed -i "s!SOURCE = \$(DESTDIR)\$(PREFIX)/lib/!SOURCE = \$(DESTDIR)\$(PREFIX)/$(get_libdir)/!" Makefile
	sed -i "s!INSTALLEDSOURCE = \$(PREFIX)/lib/!INSTALLEDSOURCE = \$(PREFIX)/$(get_libdir)/!" Makefile
	sed -i "s!INSTALLEDMODULES = \$(PREFIX)/lib/!INSTALLEDMODULES = \$(PREFIX)/$(get_libdir)/!" Makefile
}

src_configure() {
	# the configure script is handcrafted (and yells at unknown options)
	# hence do not use 'econf'
	./configure --prefix="/usr" \
		--sysconfdir="${JABBER_ETC}" \
		--datadir="${JABBER_SPOOL}" \
		--with-lua-lib=/usr/$(get_libdir)/lua \
		--c-compiler="$(tc-getCC)" --linker="$(tc-getCC)" \
		--cflags="${CFLAGS} -Wall -fPIC" \
		--ldflags="${LDFLAGS} -shared" \
		--require-config || die "configure failed"
}

src_install() {
	DESTDIR="${D}" emake install
	newinitd "${FILESDIR}/${PN}".initd.old ${PN}
	systemd_dounit "${FILESDIR}/${PN}".service
	systemd_newtmpfilesd "${FILESDIR}/${PN}".tmpfilesd "${PN}".conf
}

src_test() {
	cd tests
	./run_tests.sh
}

pkg_postinst() {
	elog "Please note that the module 'console' has been renamed to 'admin_telnet'."
}
