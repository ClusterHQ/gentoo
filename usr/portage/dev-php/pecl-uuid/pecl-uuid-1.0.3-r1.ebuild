# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-php/pecl-uuid/pecl-uuid-1.0.3-r1.ebuild,v 1.2 2014/08/10 21:04:19 slyfox Exp $

EAPI="5"

PHP_EXT_NAME="uuid"
PHP_EXT_INIT="yes"
PHP_EXT_ZENDEXT="no"
DOCS="CREDITS"

USE_PHP="php5-3 php5-4 php5-5"

inherit php-ext-pecl-r2

DESCRIPTION="A wrapper around libuuid"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="sys-apps/util-linux"
RDEPEND="${DEPEND}"
