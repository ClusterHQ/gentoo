# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-im/turses/turses-0.2.13.ebuild,v 1.2 2014/08/05 18:34:08 mrueg Exp $

EAPI=4

PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit distutils eutils vcs-snapshot

DESCRIPTION="Command line twitter client"
HOMEPAGE="https://github.com/alejandrogomez/turses"
SRC_URI="https://github.com/alejandrogomez/${PN}/tarball/v${PV} -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

DEPEND="
	dev-python/oauth2
	dev-python/setuptools
	dev-python/tweepy
	dev-python/urwid
	test? (
		dev-python/mock
		dev-python/nose
		dev-python/tox
		)

"
RDEPEND=""

DOCS="AUTHORS HISTORY.rst README.rst"
