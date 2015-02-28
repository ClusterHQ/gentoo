# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Class-Load-XS/Class-Load-XS-0.60.0-r1.ebuild,v 1.1 2014/08/21 14:17:04 axs Exp $

EAPI=5

MODULE_AUTHOR=DROLSKY
MODULE_VERSION=0.06
inherit perl-module

DESCRIPTION="XS implementation of parts of Class::Load"

LICENSE="Artistic-2"
SLOT="0"
KEYWORDS="amd64 ~arm ppc x86 ~x64-macos"
IUSE="test"

RDEPEND="
	>=dev-perl/Class-Load-0.200.0

"
DEPEND="${RDEPEND}
	>=virtual/perl-Module-Build-0.360.100
	test? (
		>=virtual/perl-Test-Simple-0.880.0
		>=dev-perl/Module-Implementation-0.40.0
		dev-perl/Test-Fatal
		dev-perl/Test-Requires
	)
"

SRC_TEST=do
