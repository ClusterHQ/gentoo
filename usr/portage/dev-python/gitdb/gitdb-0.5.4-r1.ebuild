# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/gitdb/gitdb-0.5.4-r1.ebuild,v 1.1 2013/05/07 14:47:15 idella4 Exp $

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1

DESCRIPTION="GitDB is a pure-Python git object database"
HOMEPAGE="https://github.com/gitpython-developers/gitdb
	http://pypi.python.org/pypi/gitdb"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-vcs/git
	>=dev-python/async-0.6[${PYTHON_USEDEP}]
	>=dev-python/smmap-0.8[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]"
