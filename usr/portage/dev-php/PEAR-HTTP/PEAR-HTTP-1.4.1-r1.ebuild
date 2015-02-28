# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-php/PEAR-HTTP/PEAR-HTTP-1.4.1-r1.ebuild,v 1.8 2014/08/10 20:49:50 slyfox Exp $

EAPI="2"

inherit php-pear-r1 eutils

DESCRIPTION="Miscellaneous HTTP utilities"
LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ppc ppc64 sparc x86"
IUSE=""

DEPEND="|| ( <dev-lang/php-5.3[pcre] >=dev-lang/php-5.3 )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# fix nasty DOS linebreaks
	edos2unix HTTP.php
}
