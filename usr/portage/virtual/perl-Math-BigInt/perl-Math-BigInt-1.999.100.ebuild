# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/perl-Math-BigInt/perl-Math-BigInt-1.999.100.ebuild,v 1.4 2014/08/31 17:13:32 zlogene Exp $

EAPI=5

DESCRIPTION="Virtual for ${PN#perl-}"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="alpha amd64 arm ~hppa ~ia64 ~mips ~ppc ~s390 ~sh ~sparc ~x86 ~ppc-aix ~ppc-macos ~x86-solaris"
IUSE=""

RDEPEND="
	|| ( =dev-lang/perl-5.18* ~perl-core/${PN#perl-}-${PV} )
	!<perl-core/${PN#perl-}-${PV}
	!>perl-core/${PN#perl-}-${PV}-r999
"
