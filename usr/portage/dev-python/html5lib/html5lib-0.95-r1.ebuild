# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/html5lib/html5lib-0.95-r1.ebuild,v 1.12 2014/08/13 17:43:24 blueness Exp $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} pypy pypy2_0 )
PYTHON_REQ_USE="xml(+)"

inherit distutils-r1

DESCRIPTION="HTML parser based on the HTML5 specification"
HOMEPAGE="http://code.google.com/p/html5lib/ http://pypi.python.org/pypi/html5lib"
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd"
IUSE="test"

# unittest2 used by our python_test()

RDEPEND=""
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

python_test() {
	cd "${BUILD_DIR}"/lib/html5lib/tests || die

	local test_runner=( "${PYTHON}" -m unittest )
	if [[ ${EPYTHON} == python2.[56] ]]; then
		test_runner=( unit2.py )
	fi

	"${test_runner[@]}" discover || die "Tests fail with ${EPYTHON}"
}
