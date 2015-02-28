# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Output/Test-Output-0.16.ebuild,v 1.5 2013/07/08 09:41:09 vincent Exp $

EAPI=5

MODULE_AUTHOR=BDFOY
inherit perl-module

DESCRIPTION="Utilities to test STDOUT and STDERR messages"

SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE="test"

RDEPEND="
	dev-perl/Sub-Exporter
	virtual/perl-Test-Simple"
DEPEND="${RDEPEND}
	test? ( >=dev-perl/Test-Tester-0.107
		dev-perl/Test-Pod
		dev-perl/Test-Pod-Coverage )"

SRC_TEST=do
