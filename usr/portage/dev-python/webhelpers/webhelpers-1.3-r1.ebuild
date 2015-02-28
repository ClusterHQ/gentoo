# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/webhelpers/webhelpers-1.3-r1.ebuild,v 1.3 2014/03/31 20:39:53 mgorny Exp $

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7} pypy pypy2_0 )
#DISTUTILS_SRC_TEST="nosetests"

inherit distutils-r1

MY_PN="WebHelpers"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Web Helpers"
HOMEPAGE="http://webhelpers.groovie.org/ http://pypi.python.org/pypi/WebHelpers"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="doc"

RDEPEND=">=dev-python/markupsafe-0.9.2[${PYTHON_USEDEP}]
	dev-python/webob[${PYTHON_USEDEP}]
	dev-python/routes[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )"

S="${WORKDIR}/${MY_P}"

python_prepare_all() {
	# https://bitbucket.org/bbangert/webhelpers/issue/67
	sed \
		-e '/import datetime/a import os' \
		-e 's:"/tmp/feed":os.environ.get("TMPDIR", "/tmp") + "/feed":' \
		-i tests/test_feedgenerator.py || die "sed failed"

	epatch "${FILESDIR}"/mime9ad434b.patch
}

python_compile_all() {
	use doc && emake html -C docs
}

python_test() {
	nosetests || die "Tests failed under ${EPYTHON}"
}

python_install_all() {
	if use doc; then
		pushd docs/_build/html > /dev/null
		docinto html
		insinto /usr/share/doc/${PF}/html
		doins -r [a-z]* _static || die "Installation of documentation failed"
		popd > /dev/null
	fi
	distutils-r1_python_install_all
}
