# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/simpletal/simpletal-4.2.ebuild,v 1.4 2014/08/10 21:22:29 slyfox Exp $

EAPI="3"
PYTHON_DEPEND="2:2.5"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.4 3.*"

inherit distutils

MY_PN="SimpleTAL"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Stand alone Python implementation of the Zope TAL, TALES and METAL specs for HTML/XML templates"
HOMEPAGE="http://www.owlfish.com/software/simpleTAL/ http://pypi.python.org/pypi/SimpleTAL"
SRC_URI="http://www.owlfish.com/software/simpleTAL/downloads/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="4"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~sparc ~x86"
IUSE="examples"

DEPEND="dev-python/pyxml"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_test() {
	sed -e "s/^TEMP_DIR=.*/TEMP_DIR=os.curdir/" -i tests/TALUtilsTests/TemplateCacheTestCases.py || die "sed failed"

	testing() {
		"$(PYTHON)" runtests.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	dohtml documentation/html/*

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
