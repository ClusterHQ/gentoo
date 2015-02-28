# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyopencl/pyopencl-2013.2.ebuild,v 1.1 2013/11/07 06:45:05 patrick Exp $

EAPI="4"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.* *-jython 2.7-pypy-*"

inherit distutils

DESCRIPTION="Python wrapper for OpenCL"
HOMEPAGE="http://mathema.tician.de/software/pyopencl http://pypi.python.org/pypi/pyopencl"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples opengl"

RDEPEND=">=dev-libs/boost-1.48[python]
	dev-python/decorator
	dev-python/numpy
	dev-python/mako
	dev-python/pytools
	>=virtual/opencl-0-r1"
DEPEND="${RDEPEND}"

DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES="1"

src_configure()
{
	configuration() {
		local myconf=()

		if use opengl; then
			myconf+=(--cl-enable-gl)
		fi

		"$(PYTHON)" configure.py \
			--boost-compiler=gcc \
			--boost-python-libname=boost_python-${PYTHON_ABI}-mt \
			--no-use-shipped-boost \
			"${myconf[@]}"
	}
	python_execute_function -s configuration
}

src_install()
{
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

pkg_postinst()
{
	distutils_pkg_postinst
	if use examples; then
		elog "Some of the examples provided by this package require dev-python/matplotlib."
	fi
}
