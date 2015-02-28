# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/gorg/gorg-0.6.4-r1.ebuild,v 1.7 2012/09/02 09:03:27 flameeyes Exp $

EAPI=3
USE_RUBY="ruby18"

inherit ruby-ng eutils prefix

DESCRIPTION="Back-end XSLT processor for an XML-based web site"
HOMEPAGE="http://www.gentoo.org/proj/en/gdp/doc/gorg.xml"
SRC_URI="http://gentoo.neysx.org/mystuff/gorg/${P}.tgz"
IUSE="fastcgi mysql"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

CDEPEND="
	>=dev-libs/libxml2-2.6.16
	>=dev-libs/libxslt-1.1.12"
DEPEND="${DEPEND} ${CDEPEND}"
RDEPEND="${RDEPEND} ${CDEPEND}
		fastcgi? ( virtual/httpd-fastcgi )"

ruby_add_rdepend "
	mysql? ( >=dev-ruby/dbi-0.0.21[mysql] )
	fastcgi? ( >=dev-ruby/fcgi-0.8.5-r1 )"

pkg_setup() {
	enewgroup gorg
	enewuser  gorg -1 -1 -1 gorg
}

all_ruby_prepare() {
	epatch "${FILESDIR}/${P}-ruby19.patch"
	epatch "${FILESDIR}/${P}-ruby19-date.patch"

	epatch "${FILESDIR}/${P}-prefix.patch"
	eprefixify bin/gorg etc/gorg/gorg.conf.sample \
		etc/gorg/lighttpd.conf.sample etc/gorg/vhost.sample lib/gorg/base.rb \
		lib/gorg/cgi-bin/gorg.cgi lib/gorg/cgi-bin/search.cgi \
		lib/gorg/fcgi-bin/gorg.fcgi
}

each_ruby_configure() {
	${RUBY} setup.rb config --prefix="${EPREFIX}"/usr || die
}

each_ruby_compile() {
	${RUBY} setup.rb setup || die
}

each_ruby_install() {
	${RUBY} setup.rb config --prefix="${ED}"/usr || die
	${RUBY} setup.rb install                    || die

	# install doesn't seem to chmod these correctly, forcing it here
	SITE_LIB_DIR=$(ruby_rbconfig_value 'sitelibdir')
	chmod +x "${D}"/${SITE_LIB_DIR}/gorg/cgi-bin/*.cgi
	chmod +x "${D}"/${SITE_LIB_DIR}/gorg/fcgi-bin/*.fcgi
}

all_ruby_install() {
	keepdir /etc/gorg; insinto /etc/gorg ; doins etc/gorg/*

	if use prefix; then
		diropts -m0770; keepdir /var/cache/gorg
	else
		diropts -m0770 -o gorg -g gorg; keepdir /var/cache/gorg
	fi

	dodoc Changelog README
}
