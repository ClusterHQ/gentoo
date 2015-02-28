# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/SQL-Abstract-Limit/SQL-Abstract-Limit-0.141.0.ebuild,v 1.1 2011/08/29 09:38:12 tove Exp $

EAPI=4

MODULE_AUTHOR=DAVEBAIRD
MODULE_VERSION=0.141
inherit perl-module

DESCRIPTION="Portable LIMIT emulation"

SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86 ~x86-solaris"
IUSE="test"

RDEPEND="dev-perl/SQL-Abstract
	 dev-perl/DBI"
DEPEND="${RDEPEND}
	virtual/perl-Module-Build
	test? (
		dev-perl/Test-Deep
		dev-perl/Test-Exception
	)"

SRC_TEST=do
