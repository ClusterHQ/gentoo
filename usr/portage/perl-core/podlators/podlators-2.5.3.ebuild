# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/podlators/podlators-2.5.3.ebuild,v 1.2 2014/07/31 13:12:30 civil Exp $

EAPI=5

MODULE_AUTHOR=RRA
MODULE_VERSION=2.5.3
inherit perl-module

DESCRIPTION="Format POD source into various output formats"

SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

RDEPEND=">=dev-lang/perl-5.8.8-r8
	>=virtual/perl-Pod-Simple-3.06"
DEPEND="${RDEPEND}"

SRC_TEST=parallel
