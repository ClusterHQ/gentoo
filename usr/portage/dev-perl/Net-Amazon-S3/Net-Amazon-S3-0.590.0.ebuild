# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Net-Amazon-S3/Net-Amazon-S3-0.590.0.ebuild,v 1.1 2013/08/25 10:42:35 patrick Exp $

EAPI=4

MODULE_AUTHOR=PFIG
MODULE_VERSION=0.59
inherit perl-module

DESCRIPTION="Framework for accessing the Amazon S3 Simple Storage Service"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-perl/Moose-1.990.0
	>=dev-perl/Data-Stream-Bulk-0.60.0
	dev-perl/DateTime-Format-HTTP
	dev-perl/Digest-HMAC
	dev-perl/Digest-MD5-File
	dev-perl/libwww-perl
	virtual/perl-IO
	dev-perl/LWP-UserAgent-Determined
	virtual/perl-MIME-Base64
	>=dev-perl/Moose-0.850.0
	>=dev-perl/MooseX-StrictConstructor-0.160.0
	>=dev-perl/MooseX-Types-DateTime-MoreCoercions-0.70.0
	dev-perl/regexp-common
	dev-perl/XML-LibXML
	dev-perl/URI"

RDEPEND="${DEPEND}"

SRC_TEST=no
