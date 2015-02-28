# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyroma/pyroma-1.5.ebuild,v 1.2 2014/06/30 04:33:16 floppym Exp $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3} )

inherit distutils-r1

DESCRIPTION="Test project's packaging friendliness"
HOMEPAGE="https://bitbucket.org/regebro/pyroma https://pypi.python.org/pypi/pyroma"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND=""

DOCS=( README.txt HISTORY.txt )

python_test() {
	"${PYTHON}" setup.py test || die "Testing failed with ${EPYTHON}"
}
