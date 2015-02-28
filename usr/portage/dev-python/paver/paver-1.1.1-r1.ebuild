# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/paver/paver-1.1.1-r1.ebuild,v 1.9 2014/08/21 12:40:12 armin76 Exp $

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7} pypy pypy2_0 )
# Trivial test fail under pypy:
# https://github.com/paver/paver/pull/88

inherit distutils-r1

MY_PN=${PN/p/P}
MY_P=${MY_PN}-${PV}

DESCRIPTION="Python-based software project scripting tool along the lines of Make"
HOMEPAGE="http://www.blueskyonmars.com/projects/paver/ http://pypi.python.org/pypi/Paver"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 ~hppa ~ia64 ~ppc ~sparc x86"
IUSE="doc test"

RDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	test? ( dev-python/nose[${PYTHON_USEDEP}] )"

S=${WORKDIR}/${MY_P}

DOCS="README.rst"

python_install_all() {
	use doc && dohtml -r paver/docs/*
}

python_test() {
	nosetests || die
}
