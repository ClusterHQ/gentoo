# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/yworklog/yworklog-0.0.7.ebuild,v 1.1 2013/06/09 01:08:24 yac Exp $

EAPI=5
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE=sqlite

inherit distutils-r1

DESCRIPTION="Stack based utility with CLI interface helping to monitor time spent on tasks"
HOMEPAGE="https://github.com/yaccz/worklog"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-python/sqlalchemy
	dev-python/cement[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	dev-python/alembic[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"
