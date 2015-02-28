# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/MooseX-Types-DateTimeX/MooseX-Types-DateTimeX-0.60.0.ebuild,v 1.1 2011/08/29 17:36:07 tove Exp $

EAPI=4

MODULE_AUTHOR=ECARROLL
MODULE_VERSION=0.06
inherit perl-module

DESCRIPTION="DateTime related constraints and coercions for Moose"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND="dev-perl/Moose
	>=dev-perl/MooseX-Types-0.04
	>=dev-perl/namespace-clean-0.08
	>=dev-perl/Time-Duration-Parse-0.06
	>=dev-perl/MooseX-Types-DateTime-ButMaintained-0.04
	>=dev-perl/DateTimeX-Easy-0.085"
DEPEND="${RDEPEND}
	test? (
		>=dev-perl/Test-use-ok-0.02
		>=dev-perl/Test-Exception-0.27
	)"

SRC_TEST=do
