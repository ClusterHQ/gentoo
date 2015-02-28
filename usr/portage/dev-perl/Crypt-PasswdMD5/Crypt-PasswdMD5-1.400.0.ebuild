# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Crypt-PasswdMD5/Crypt-PasswdMD5-1.400.0.ebuild,v 1.1 2014/03/09 03:20:43 radhermit Exp $

EAPI=5

MODULE_AUTHOR=RSAVAGE
MODULE_VERSION=1.40
MODULE_A_EXT=tgz
inherit perl-module

DESCRIPTION="Provides interoperable MD5-based crypt() functions"
SLOT="0"
KEYWORDS="~amd64 ~arm ~mips ~ppc ~ppc64 ~sparc ~x86"

DEPEND="virtual/perl-Module-Build"

SRC_TEST="do"
