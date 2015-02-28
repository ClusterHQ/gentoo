# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-SubCalls/Test-SubCalls-1.90.0-r1.ebuild,v 1.1 2014/08/24 01:18:06 axs Exp $

EAPI=5

MODULE_AUTHOR=ADAMK
MODULE_VERSION=1.09
inherit perl-module

DESCRIPTION="Track the number of times subs are called"

SLOT="0"
KEYWORDS="amd64 ~arm ~ppc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND=">=dev-perl/Hook-LexWrap-0.20
	virtual/perl-File-Spec"
RDEPEND="${DEPEND}"

SRC_TEST="do"
