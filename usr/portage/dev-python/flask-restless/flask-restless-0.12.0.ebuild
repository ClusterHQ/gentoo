# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/flask-restless/flask-restless-0.12.0.ebuild,v 1.3 2014/07/06 12:41:46 mgorny Exp $

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1

DESCRIPTION="Flask extension for easy ReSTful API generation"
HOMEPAGE="http://packages.python.org/Flask-Restless/"
SRC_URI="https://github.com/jfinkels/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="|| ( AGPL-3 BSD )"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="doc examples test"

RDEPEND=">=dev-python/flask-0.7[${PYTHON_USEDEP}]
	dev-python/flask-sqlalchemy[${PYTHON_USEDEP}]
	dev-python/sqlalchemy[${PYTHON_USEDEP}]
	dev-python/python-dateutil:0[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? ( dev-python/nose[${PYTHON_USEDEP}] )
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}]
		>=dev-python/sphinxcontrib-httpdomain-1.1.7[${PYTHON_USEDEP}]
		>=dev-python/sphinxcontrib-issuetracker-0.11[${PYTHON_USEDEP}]
		dev-python/flask-themes[${PYTHON_USEDEP}] )"

PATCHES=( "${FILESDIR}"/docbuild.patch )

python_compile_all() {
	if use doc; then
		if ! "${PYTHON}" -c "import flask_restless"; then
			eerror "flask-restless is not installed. Building of the docs"
			eerror "requires flask-restless to already be installed."
			eerror "Firstly emerge without USE=doc, then re-emerge with USE=doc"
			eerror ""
			die
		fi
		# Changes connect to read issues @ github
		rm -f docs/changelog.rst
		einfo "Generating html docs for ${PN}"
		PYTHONPATH=${PYTHONPATH}"${S}"/docs emake -C docs html \
			|| die "Generating html docs for ${PN} failed"
	fi
}

python_test() {
	nosetests tests/test_*.py || die "Tests failed under ${EPYTHON}"
}

python_install_all() {
	use doc && local HTML_DOCS=( docs/_build/html/. )
	use examples && local EXAMPLES=( examples/. )
	distutils-r1_python_install_all
}
