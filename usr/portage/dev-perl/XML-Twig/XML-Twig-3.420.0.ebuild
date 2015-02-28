# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/XML-Twig/XML-Twig-3.420.0.ebuild,v 1.8 2013/03/31 09:56:03 ago Exp $

EAPI=4

MODULE_AUTHOR=MIROD
MODULE_VERSION=3.42
inherit perl-module

DESCRIPTION="Process huge XML documents in tree mode"

SLOT="0"
KEYWORDS="alpha amd64 ~hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="nls"

RDEPEND="
	>=dev-perl/XML-Parser-2.31
	virtual/perl-Scalar-List-Utils
	>=dev-libs/expat-1.95.5
	dev-perl/Tie-IxHash
	dev-perl/XML-SAX-Writer
	dev-perl/XML-Handler-YAWriter
	dev-perl/XML-XPath
	dev-perl/libwww-perl
	nls? (
		>=dev-perl/Text-Iconv-1.2-r1
	)
"
DEPEND="${RDEPEND}"

SRC_TEST="do"
