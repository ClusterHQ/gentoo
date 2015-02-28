# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/perl-bignum/perl-bignum-0.300.0.ebuild,v 1.1 2014/07/10 22:25:58 dilfridge Exp $

EAPI=5

DESCRIPTION="Virtual for ${PN#perl-}"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc s390 sh sparc x86 ~ppc-aix ~ppc-macos ~x86-solaris"

IUSE=""
RDEPEND="~perl-core/${PN#perl-}-${PV}"
