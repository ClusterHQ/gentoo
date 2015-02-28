# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/fabric/fabric-1.5.2.ebuild,v 1.2 2014/08/10 21:10:24 slyfox Exp $

EAPI="4"
PYTHON_DEPEND="2:2.5"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.4 3.* *-jython *-pypy-*"
DISTUTILS_SRC_TEST="nosetests"

# Requires multiprocessing package from py2.6+
PYTHON_TESTS_RESTRICTED_ABIS="2.5"

inherit distutils

MY_PN="Fabric"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Fabric is a simple, Pythonic tool for remote execution and deployment"
HOMEPAGE="http://fabfile.org http://pypi.python.org/pypi/Fabric"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND="dev-python/paramiko"
DEPEND="${RDEPEND}
	dev-python/setuptools
	doc? ( dev-python/sphinx )
	test? ( <dev-python/fudge-1.0 )"

S="${WORKDIR}/${MY_P}"
PYTHON_MODULES="fabfile fabric"

src_compile() {
	distutils_src_compile

	if use doc; then
		emake -C docs html
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
