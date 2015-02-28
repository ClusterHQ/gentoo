# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DelimMatch/DelimMatch-1.06-r1.ebuild,v 1.7 2013/12/08 15:37:46 zlogene Exp $

EAPI=5

inherit perl-module
MY_P=${P}a

DESCRIPTION="A Perl 5 module for locating delimited substrings with proper nesting"
SRC_URI="mirror://cpan/authors/id/N/NW/NWALSH/${MY_P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~nwalsh/"

LICENSE="|| ( Artistic GPL-1+ )"
SLOT="0"
KEYWORDS="alpha amd64 ~hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND="dev-lang/perl"
RDEPEND=""

SRC_TEST="do"
