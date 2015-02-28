# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygraphviz/pygraphviz-1.1-r2.ebuild,v 1.2 2013/04/26 20:45:13 mgorny Exp $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1

DESCRIPTION="Python wrapper for the Graphviz Agraph data structure"
HOMEPAGE="http://networkx.lanl.gov/pygraphviz/ http://pypi.python.org/pypi/pygraphviz"
SRC_URI="http://networkx.lanl.gov/download/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86 ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="examples"

# Note: only C API of graphviz is used, PYTHON_USEDEP unnecessary.
RDEPEND="media-gfx/graphviz"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/${PN}-1.0-setup.py.patch
	"${FILESDIR}"/${P}-avoid_tests.patch
)

python_test() {
	PYTHONPATH=${PYTHONPATH}:${BUILD_DIR}/lib/pygraphviz \
	"${PYTHON}" \
		-c "import pygraphviz.tests; pygraphviz.tests.run()" \
		|| die "Tests fail with ${EPYTHON}"
}

python_install_all() {
	use examples && local EXAMPLES=( examples/. )

	distutils-r1_python_install_all
}
