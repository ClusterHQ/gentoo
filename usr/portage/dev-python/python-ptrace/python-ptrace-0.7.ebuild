# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/python-ptrace/python-ptrace-0.7.ebuild,v 1.2 2014/08/10 21:19:40 slyfox Exp $

EAPI=5
PYTHON_COMPAT=( python{2_7,3_3,3_4} pypy2_0 pypy )

inherit distutils-r1

DESCRIPTION="python-ptrace is a debugger using ptrace (Linux, BSD and Darwin system call to trace processes)"
HOMEPAGE="http://bitbucket.org/haypo/python-ptrace/ http://pypi.python.org/pypi/python-ptrace"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples"

DEPEND=""
RDEPEND="dev-libs/distorm64"
# Req'd for tests
DISTUTILS_IN_SOURCE_BUILD=1

python_test() {
	echo "${EPYTHON}"
	if python_is_python3; then
		2to3 -w ptrace
	fi
	"${PYTHON}" test_doc.py || die "tests failed under ${EPYTHON}"
}

python_install_all() {
	use examples && local EXAMPLES=( examples/. )

	distutils-r1_python_install_all
}
