# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-php/pecl-imagick/pecl-imagick-3.1.0_rc2.ebuild,v 1.6 2014/08/10 21:02:21 slyfox Exp $

EAPI=4

PHP_EXT_NAME="imagick"
PHP_EXT_INI="yes"
PHP_EXT_ZENDEXT="no"
DOCS="TODO"

MY_PV="${PV/_/}"
MY_PV="${MY_PV/rc/RC}"
PECL_PKG_V="${PECL_PKG}-${MY_PV}"
FILENAME="${PECL_PKG_V}.tgz"
S="${WORKDIR}/${PECL_PKG_V}"

USE_PHP="php5-5 php5-3 php5-4"

inherit php-ext-pecl-r2

KEYWORDS="amd64 x86"

DESCRIPTION="PHP wrapper for the ImageMagick library"
LICENSE="PHP-3.01"
SLOT="0"
IUSE="examples"

DEPEND=">=media-gfx/imagemagick-6.2.4"
RDEPEND="${DEPEND}"

SRC_URI="http://pecl.php.net/get/${FILENAME}"

my_conf="--with-imagick=/usr"

src_prepare() {
	local slot
	for slot in $(php_get_slots) ; do
		cd "${WORKDIR}/${slot}"
		epatch "${FILESDIR}/remove-header-check.patch"
	done
	php-ext-source-r2_src_prepare
}
