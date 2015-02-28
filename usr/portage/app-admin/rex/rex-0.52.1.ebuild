# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/rex/rex-0.52.1.ebuild,v 1.1 2014/09/11 03:54:11 patrick Exp $

EAPI=5

inherit perl-module

SRC_URI="https://github.com/RexOps/Rex/archive/${PV}.tar.gz"

DESCRIPTION="(R)?ex is a small script to ease the execution of remote commands"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-perl/Net-SSH2"
DEPEND="${RDEPEND}
	dev-perl/JSON-XS
	dev-perl/XML-Simple
	dev-perl/Digest-SHA1
	dev-perl/Digest-HMAC
	dev-perl/Expect
	dev-perl/DBI
	dev-perl/yaml
	dev-perl/libwww-perl
	dev-perl/String-Escape
	dev-perl/List-MoreUtils
	dev-perl/Parallel-ForkManager"

SRC_TEST="do"

S="${WORKDIR}/Rex-${PV}"
