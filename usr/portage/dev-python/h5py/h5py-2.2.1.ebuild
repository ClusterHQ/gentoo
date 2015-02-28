# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/h5py/h5py-2.2.1.ebuild,v 1.2 2014/07/06 12:41:32 mgorny Exp $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3} )

inherit distutils-r1 flag-o-matic

DESCRIPTION="Simple Python interface to HDF5 files"
HOMEPAGE="http://www.h5py.org/"
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="test examples"

RDEPEND="
	sci-libs/hdf5:=
	dev-python/numpy[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/cython[${PYTHON_USEDEP}]"

python_prepare_all() {
	append-cflags -fno-strict-aliasing
	distutils-r1_python_prepare_all
}

python_test() {
	cd "${BUILD_DIR}"/lib/ && nosetests ./${PN}/lowtest || die
}

python_install_all() {
	DOCS=( README.rst ANN.rst )
	if use examples; then
		docompress -x /usr/share/doc/${PF}/examples
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
	distutils-r1_python_install_all
}
