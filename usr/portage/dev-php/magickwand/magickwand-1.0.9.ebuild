# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-php/magickwand/magickwand-1.0.9.ebuild,v 1.3 2014/08/10 21:00:16 slyfox Exp $

EAPI="4"

PHP_EXT_NAME="magickwand"
PHP_EXT_ZENDEXT="no"
PHP_EXT_INI="yes"
DOCS="AUTHOR ChangeLog CREDITS README TODO"

MY_PN="MagickWandForPHP"
IUSE=""

USE_PHP="php5-5 php5-3 php5-4"

S="${WORKDIR}/${MY_PN}-${PV}"

inherit php-ext-source-r2

DESCRIPTION="A native PHP-extension to the ImageMagick MagickWand API"
HOMEPAGE="http://www.magickwand.org/"
SRC_URI="http://www.magickwand.org/download/php/${MY_PN}-${PV}-2.tar.bz2"

LICENSE="MagickWand"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=media-gfx/imagemagick-6.5.2.9"
RDEPEND="${DEPEND}"
