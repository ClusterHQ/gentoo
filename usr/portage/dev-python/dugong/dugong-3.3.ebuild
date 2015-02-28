# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/dugong/dugong-3.3.ebuild,v 1.2 2014/08/20 07:57:24 idella4 Exp $

EAPI=5
PYTHON_COMPAT=( python3_{3,4} )

inherit distutils-r1

DESCRIPTION="Python library for communicating with HTTP 1.1 servers"
HOMEPAGE="https://bitbucket.org/nikratio/python-dugong/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples test"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	test? ( dev-python/pytest[${PYTHON_USEDEP}] )"

PATCHES=( "${FILESDIR}"/3.3-test-timeout.patch
		"${FILESDIR}"/3.2-extract_links.patch )

python_test() {
	# https://bitbucket.org/nikratio/python-dugong/issue/12
	einfo "Test suite can take several minutes to complete"
	py.test -v || die "Tests failed under ${EPYTHON}"
}

python_install_all() {
	use doc && local HTML_DOCS=( doc/html/. )
	use examples && local EXAMPLES=( examples/. )
	distutils-r1_python_install_all
}
