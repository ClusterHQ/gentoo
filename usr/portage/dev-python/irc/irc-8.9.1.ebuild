# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/irc/irc-8.9.1.ebuild,v 1.3 2014/08/10 21:12:14 slyfox Exp $

EAPI=5
PYTHON_COMPAT=( python{2_7,3_2,3_3,3_4} )

inherit distutils-r1

DESCRIPTION="IRC client framework written in Python"
HOMEPAGE="https://bitbucket.org/jaraco/irc http://pypi.python.org/pypi/irc"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples test"

DEPEND="app-arch/unzip
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? ( dev-python/jaraco-utils[${PYTHON_USEDEP}]
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/mock[${PYTHON_USEDEP}] )"

RDEPEND="!>=dev-python/python-irclib-3.2.2[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]"

PATCHES=(
	"${FILESDIR}/irc-8.5.1-setup_requires.patch"
)

python_prepare_all() {
	# Don't rely on hgtools for version
	sed -e "s/use_hg_version=True/version=\"${PV}\"/" -i setup.py || die
	sed -e "/^tag_/d" -i setup.cfg || die

	distutils-r1_python_prepare_all
}

python_test() {
	py.test irc/tests || die "Tests failed under ${EPYTHON}"
}

python_install_all() {
	use examples && local EXAMPLES=( scripts/. )
	distutils-r1_python_install_all
}
