# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/cherokee/cherokee-1.2.101-r3.ebuild,v 1.3 2014/08/10 20:08:32 slyfox Exp $

EAPI=4
PYTHON_DEPEND="admin? 2"
PYTHON_USE_WITH="threads"

inherit eutils multilib pam python versionator systemd user

DESCRIPTION="An extremely fast and tiny web server"
SRC_URI="http://www.cherokee-project.com/download/$(get_version_component_range 1-2)/${PV}/${P}.tar.gz"
HOMEPAGE="http://www.cherokee-project.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~mips ~ppc ~ppc64 ~x86"
IUSE="admin ffmpeg debug geoip ipv6 kernel_linux ldap mysql nls pam php rrdtool ssl static static-libs"

COMMON_DEPEND="dev-libs/libpcre
	>=sys-libs/zlib-1.1.4-r1
	ffmpeg? ( virtual/ffmpeg )
	geoip? ( dev-libs/geoip )
	ldap? ( net-nds/openldap )
	mysql? ( >=virtual/mysql-5 )
	nls? ( virtual/libintl )
	pam? ( virtual/pam )
	php? ( || (
		dev-lang/php[fpm]
		dev-lang/php[cgi]
	) )
	ssl? ( dev-libs/openssl )"
DEPEND="${COMMON_DEPEND}
	nls? ( sys-devel/gettext )"
RDEPEND="${COMMON_DEPEND}
	rrdtool? ( net-analyzer/rrdtool )"

RESTRICT="test"

WEBROOT="/var/www/localhost"

pkg_setup() {
	python_pkg_setup

	python_set_active_version 2

	enewgroup cherokee
	enewuser cherokee -1 -1 /var/www cherokee
}

src_prepare() {
	epatch \
		"${FILESDIR}/${PN}-1.2.99-gentoo.patch" \
		"${FILESDIR}/${PN}-1.2.98-linux3.patch" \
		"${FILESDIR}/${P}-libav-9.patch"

	python_convert_shebangs -r 2 .
}

src_configure() {
	local myconf

	if use admin ; then
		myconf="${myconf} --enable-admin --with-python=$(PYTHON -2)"
	else
		myconf="${myconf} --disable-admin --without-python"
	fi

	# Uses autodetect because --with-php requires path to php-{fpm,cgi}.
	if ! use php ; then
		myconf="${myconf} --without-php"
	fi

	if use static ; then
		myconf="${myconf} --enable-static-module=all"
	fi

	local os="Unknown"
	case "${CHOST}" in
		*-freebsd*)
			os="FreeBSD" ;;
		*-netbsd*)
			os="NetBSD" ;;
		*-openbsd*)
			os="OpenBSD" ;;
		*)
			os="Linux" ;;
	esac

	# This make cherokee 1.2 sad
	#	$(use_enable threads pthread) \
	econf \
		$(use_enable debug trace) \
		$(use_enable debug backtraces) \
		$(use_enable ipv6) \
		$(use_enable kernel_linux epoll) \
		$(use_enable nls) \
		$(use_enable pam) \
		$(use_enable static-libs static) \
		$(use_with ffmpeg) \
		$(use_with geoip) \
		$(use_with ldap) \
		$(use_with mysql) \
		$(use_with ssl libssl) \
		--disable-dependency-tracking \
		--docdir="${EPREFIX}/usr/share/doc/${PF}/html" \
		--enable-os-string="Gentoo ${os}" \
		--enable-tmpdir="${EPREFIX}/var/tmp" \
		--localstatedir="${EPREFIX}/var" \
		--with-wwwroot="${EPREFIX}${WEBROOT}/htdocs" \
		--with-cgiroot="${EPREFIX}${WEBROOT}/cgi-bin" \
		--with-wwwuser=cherokee \
		--with-wwwgroup=cherokee \
		${myconf}
}

src_install() {
	emake DESTDIR="${D}" install

	if ! use static-libs ; then
		find "${ED}" -name '*.la' -delete || die
	elif ! use static ; then
		find "${ED}/usr/$(get_libdir)/cherokee" '(' -name '*.la' -o -name '*.a' ')' -delete || die
	fi

	dodoc AUTHORS ChangeLog README

	if use pam ; then
		pamd_mimic system-auth cherokee auth account session || die
	fi

	newinitd "${FILESDIR}/${PN}-initd-1.2.99" ${PN}
	newconfd "${FILESDIR}/${PN}-confd-1.2.98" ${PN}

	if ! use admin ; then
		rm -r \
			"${ED}"/usr/bin/cherokee-admin-launcher \
			"${ED}"/usr/bin/CTK-run \
			"${ED}"/usr/sbin/cherokee-admin \
			"${ED}"/usr/share/cherokee/admin || die
	fi

	exeinto /usr/share/doc/${PF}/contrib
	doexe contrib/{bin2buffer.py,make-cert.sh,make-dh_params.sh,tracelor.py}

	#move the htdocs to docdir, bug #429632
	docompress -x /usr/share/doc/"${PF}"/htdocs.dist
	mv "${ED}"${WEBROOT}/htdocs \
		"${ED}"/usr/share/doc/"${PF}"/htdocs.dist
	mkdir "${ED}"${WEBROOT}/htdocs

	keepdir \
		"${WEBROOT}"/htdocs \
		/var/log/cherokee \
		/var/lib/cherokee/graphs/images
	fowners cherokee:cherokee \
		/var/log/cherokee \
		/var/lib/cherokee/graphs \
		/var/lib/cherokee/graphs/images

	# logrotate
	insinto /etc/logrotate.d
	newins "${FILESDIR}"/${PN}.logrotate-r1 ${PN}

	systemd_dounit "${FILESDIR}"/cherokee.service
}

pkg_postinst() {
	elog
	if use admin ; then
		python_mod_optimize "${EPREFIX}/usr/share/cherokee/admin/"
		elog "Just run '/usr/sbin/cherokee-admin' and go to: http://localhost:9090"
		elog
		elog "Cherokee currently supports configuration versioning, so from now on,"
		elog "whenever a change is made to the configuration file format,"
		elog "Cherokee-Admin will be able to automatically convert yours to the new"
		elog "release. You simply have to load Cherokee-Admin and it will be converted"
		elog "once you proceed to saving it."
		elog
		elog "There is also a command line utility that you can use to do the exact"
		elog "same thing. Config format can change in different versions. It is"
		elog "provided under:"
		elog "	${EPREFIX}/usr/share/cherokee/admin/upgrade_config.py"
	else
		elog "Try USE=admin if you want an easy way to configure cherokee."
	fi
	elog
	elog "emerge www-servers/spawn-fcgi if you use Ruby on Rails with ${PN}."
	elog
}

pkg_postrm() {
	if use admin ; then
		python_mod_cleanup "${EPREFIX}/usr/share/cherokee/admin/"
	fi
}
