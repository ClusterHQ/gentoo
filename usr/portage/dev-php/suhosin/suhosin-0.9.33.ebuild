# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-php/suhosin/suhosin-0.9.33.ebuild,v 1.13 2014/08/10 21:06:05 slyfox Exp $

EAPI="5"

PHP_EXT_NAME="suhosin"
PHP_EXT_INI="yes"
PHP_EXT_ZENDEXT="no"

inherit php-ext-source-r2

KEYWORDS="alpha amd64 arm hppa ia64 ~ppc ~ppc64 ~s390 ~sh sparc x86"

DESCRIPTION="Suhosin is an advanced protection system for PHP installations"
HOMEPAGE="http://www.suhosin.org/"
SRC_URI="http://download.suhosin.org/${P}.tgz"
LICENSE="PHP-3"
SLOT="0"
IUSE=""

DEPEND="dev-lang/php[unicode]"
RDEPEND="${DEPEND}"

src_prepare() {
	local slot
	for slot in $(php_get_slots); do
		php_init_slot_env ${slot}
		epatch "${FILESDIR}"/${P}-libcrypt.patch
		epatch "${FILESDIR}"/${P}-fix-ZTS-compile-problem.patch
	done
	php-ext-source-r2_src_prepare
}

src_install() {
	php-ext-source-r2_src_install
	dodoc CREDITS

	local slot
	for slot in $(php_get_slots); do
		php_init_slot_env ${slot}
		for inifile in ${PHPINIFILELIST} ; do
			insinto "${inifile/${PHP_EXT_NAME}.ini/}"
			insopts -m644
			doins "suhosin.ini"
		done
	done
}

src_test() {
	# Makefile passes a hard-coded -d extension_dir=./modules, we move the lib
	# away from there in src_compile
	for slot in `php_get_slots`; do
		php_init_slot_env ${slot}
		NO_INTERACTION="yes" emake test || die "emake test failed for slot ${slot}"
	done
}
