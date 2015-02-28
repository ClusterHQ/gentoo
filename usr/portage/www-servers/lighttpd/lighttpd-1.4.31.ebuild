# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/lighttpd/lighttpd-1.4.31.ebuild,v 1.10 2012/09/09 17:05:15 armin76 Exp $

EAPI="4"

inherit base autotools eutils depend.php user

DESCRIPTION="Lightweight high-performance web server"
HOMEPAGE="http://www.lighttpd.net/"
SRC_URI="http://download.lighttpd.net/lighttpd/releases-1.4.x/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~x64-macos ~x86-macos"
IUSE="bzip2 doc fam gdbm ipv6 kerberos ldap libev lua minimal mmap memcache mysql pcre php rrdtool selinux ssl test uploadprogress webdav xattr zlib"

REQUIRED_USE="kerberos? ( ssl )"

RDEPEND="
	bzip2?    ( app-arch/bzip2 )
	fam?      ( virtual/fam )
	gdbm?     ( sys-libs/gdbm )
	ldap?     ( >=net-nds/openldap-2.1.26 )
	libev?    ( >=dev-libs/libev-4.01 )
	lua?      ( >=dev-lang/lua-5.1 )
	memcache? ( dev-libs/libmemcache )
	mysql?    ( >=virtual/mysql-4.0 )
	pcre?     ( >=dev-libs/libpcre-3.1 )
	php?      ( dev-lang/php[cgi] )
	rrdtool?  ( net-analyzer/rrdtool )
	selinux? ( sec-policy/selinux-apache )
	ssl?    ( >=dev-libs/openssl-0.9.7[kerberos?] )
	webdav? (
		dev-libs/libxml2
		>=dev-db/sqlite-3
		!x86-interix? ( sys-fs/e2fsprogs )
	)
	xattr? ( kernel_linux? ( sys-apps/attr ) )
	zlib? (	>=sys-libs/zlib-1.1 )"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc?  ( dev-python/docutils )
	test? (
		virtual/perl-Test-Harness
		dev-libs/fcgi
	)"

# update certain parts of lighttpd.conf based on conditionals
update_config() {
	local config="${ED}/etc/lighttpd/lighttpd.conf"

	# enable php/mod_fastcgi settings
	use php && { sed -i -e 's|#.*\(include.*fastcgi.*$\)|\1|' ${config} || die; }

	# enable stat() caching
	use fam && { sed -i -e 's|#\(.*stat-cache.*$\)|\1|' ${config} || die; }

	# automatically listen on IPv6 if built with USE=ipv6. Bug #234987
	use ipv6 && { sed -i -e 's|# server.use-ipv6|server.use-ipv6|' ${config} || die; }
}

# remove non-essential stuff (for USE=minimal)
remove_non_essential() {
	local libdir="${ED}/usr/$(get_libdir)/${PN}"

	# text docs
	use doc || rm -fr "${ED}"/usr/share/doc/${PF}/txt

	# non-essential modules
	rm -f \
		${libdir}/mod_{compress,evhost,expire,proxy,scgi,secdownload,simple_vhost,status,setenv,trigger*,usertrack}.*

	# allow users to keep some based on USE flags
	use pcre    || rm -f ${libdir}/mod_{ssi,re{direct,write}}.*
	use webdav  || rm -f ${libdir}/mod_webdav.*
	use mysql   || rm -f ${libdir}/mod_mysql_vhost.*
	use lua     || rm -f ${libdir}/mod_{cml,magnet}.*
	use rrdtool || rm -f ${libdir}/mod_rrdtool.*
	use zlib    || rm -f ${libdir}/mod_compress.*
}

pkg_setup() {
	if ! use pcre ; then
		ewarn "It is highly recommended that you build ${PN}"
		ewarn "with perl regular expressions support via USE=pcre."
		ewarn "Otherwise you lose support for some core options such"
		ewarn "as conditionals and modules such as mod_re{write,direct}"
		ewarn "and mod_ssi."
	fi
	if use mmap; then
		ewarn "You have enabled the mmap option. This option may allow"
		ewarn "local users to trigger SIGBUG crashes. Use this option"
		ewarn "with EXTRA care."
	fi
	enewgroup lighttpd
	enewuser lighttpd -1 -1 /var/www/localhost/htdocs lighttpd
}

src_prepare() {
	base_src_prepare
	#dev-python/docutils installs rst2html.py not rst2html
	sed -i -e 's|\(rst2html\)|\1.py|g' doc/outdated/Makefile.am || \
		die "sed doc/Makefile.am failed"

	epatch "${FILESDIR}"/${PN}-darwin-bundle.patch

	# Experimental patch for progress bar. Bug #380093
	if use uploadprogress; then
	    epatch "${FILESDIR}"/${PN}-1.4.29-mod_uploadprogress.patch
	fi
	epatch "${FILESDIR}"/${P}-automake-1.12.patch
	eautoreconf
}
src_configure() {
	econf --libdir="${EPREFIX}/usr/$(get_libdir)/${PN}" \
		--enable-lfs \
		$(use_enable ipv6) \
		$(use_enable mmap) \
		$(use_with bzip2) \
		$(use_with fam) \
		$(use_with gdbm) \
		$(use_with kerberos kerberos5) \
		$(use_with ldap) \
		$(use_with libev) \
		$(use_with lua) \
		$(use_with memcache) \
		$(use_with mysql) \
		$(use_with pcre) \
		$(use_with ssl openssl) \
		$(use_with webdav webdav-props) \
		$(use_with webdav webdav-locks) \
		$(use_with xattr attr) \
		$(use_with zlib)
}

src_compile() {
	emake

	if use doc ; then
		einfo "Building HTML documentation"
		cd doc || die
		emake html
	fi
}

src_test() {
	if [[ ${EUID} -eq 0 ]]; then
		default_src_test
	else
		ewarn "test skipped, please re-run as root if you wish to test ${PN}"
	fi
}

src_install() {
	emake DESTDIR="${D}" install

	# init script stuff
	newinitd "${FILESDIR}"/lighttpd.initd lighttpd
	newconfd "${FILESDIR}"/lighttpd.confd lighttpd
	use fam && has_version app-admin/fam && \
		{ sed -i 's/after famd/need famd/g' "${ED}"/etc/init.d/lighttpd || die; }

	# configs
	insinto /etc/lighttpd
	doins "${FILESDIR}"/conf/lighttpd.conf
	doins "${FILESDIR}"/conf/mime-types.conf
	doins "${FILESDIR}"/conf/mod_cgi.conf
	doins "${FILESDIR}"/conf/mod_fastcgi.conf
	# Secure directory for fastcgi sockets
	keepdir /var/run/lighttpd/
	fperms 0750 /var/run/lighttpd/
	fowners lighttpd:lighttpd /var/run/lighttpd/

	# update lighttpd.conf directives based on conditionals
	update_config

	# docs
	dodoc AUTHORS README NEWS doc/scripts/*.sh
	newdoc doc/config//lighttpd.conf lighttpd.conf.distrib

	use doc && dohtml -r doc/*

	docinto txt
	dodoc doc/outdated/*.txt

	# logrotate
	insinto /etc/logrotate.d
	newins "${FILESDIR}"/lighttpd.logrotate lighttpd

	keepdir /var/l{ib,og}/lighttpd /var/www/localhost/htdocs
	fowners lighttpd:lighttpd /var/l{ib,og}/lighttpd
	fperms 0750 /var/l{ib,og}/lighttpd

	#spawn-fcgi may optionally be installed via www-servers/spawn-fcgi
	rm -f "${ED}"/usr/bin/spawn-fcgi "${ED}"/usr/share/man/man1/spawn-fcgi.*

	use minimal && remove_non_essential
}

pkg_postinst () {
	if use ipv6; then
		elog "IPv6 migration guide:"
		elog "http://redmine.lighttpd.net/projects/lighttpd/wiki/IPv6-Config"
	fi
	if [[ -f ${EROOT}etc/conf.d/spawn-fcgi.conf ]] ; then
		einfo "spawn-fcgi is now provided by www-servers/spawn-fcgi."
		einfo "spawn-fcgi's init script configuration is now located"
		einfo "at /etc/conf.d/spawn-fcgi."
	fi

	if [[ -f ${EROOT}etc/lighttpd.conf ]] ; then
		elog "Gentoo has a customized configuration,"
		elog "which is now located in /etc/lighttpd.  Please migrate your"
		elog "existing configuration."
	fi

	if use uploadprogress; then
		elog "WARNING! mod_uploadprogress is a backported module from the"
		elog "1.5x-branch, which is not considered stable yet. Please go to"
		elog "http://redmine.lighttpd.net/wiki/1/Docs:ModUploadProgress"
		elog "for more information. This configuration also is NOT supported"
		elog "by upstream, so please refrain from reporting bugs. You have"
		elog "been warned!"
	fi
}
