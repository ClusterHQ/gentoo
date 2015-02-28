# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/set-scalar/set-scalar-1.260.0-r1.ebuild,v 1.1 2014/08/22 17:27:20 axs Exp $

EAPI=5

MY_PN=Set-Scalar
MODULE_AUTHOR=JHI
MODULE_VERSION=1.26
inherit perl-module

DESCRIPTION="Scalar set operations"

SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~m68k ppc ~s390 ~sh sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

SRC_TEST="do"
