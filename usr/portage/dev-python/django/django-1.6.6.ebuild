# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/django/django-1.6.6.ebuild,v 1.3 2014/09/02 07:35:08 ago Exp $

EAPI=5
PYTHON_COMPAT=( python{2_7,3_3,3_4} pypy )
PYTHON_REQ_USE='sqlite?'
WEBAPP_NO_AUTO_INSTALL="yes"

inherit bash-completion-r1 distutils-r1 versionator webapp

MY_P="Django-${PV}"

DESCRIPTION="High-level Python web framework"
HOMEPAGE="http://www.djangoproject.com/ http://pypi.python.org/pypi/Django"
SRC_URI="https://www.djangoproject.com/m/releases/$(get_version_component_range 1-2)/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~ia64 ~ppc ~ppc64 ~sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="doc mysql postgres sqlite test"

RDEPEND="virtual/python-imaging[${PYTHON_USEDEP}]
	postgres? ( $(python_gen_cond_dep 'dev-python/psycopg:2[${PYTHON_USEDEP}]' python2_7 'python{3_3,3_4}') )
	mysql? ( $(python_gen_cond_dep '>=dev-python/mysql-python-1.2.3[${PYTHON_USEDEP}]' python2_7) )"
DEPEND="${RDEPEND}
	doc? ( >=dev-python/sphinx-1.0.7[${PYTHON_USEDEP}] )
	test? ( ${PYTHON_DEPS//sqlite?/sqlite} )"

S="${WORKDIR}/${MY_P}"

WEBAPP_MANUAL_SLOT="yes"

PATCHES=( "${FILESDIR}"/${PN}-1.5-py3tests.patch \
		"${FILESDIR}"/${PN}-1.6-objects.patch )

python_prepare_all() {
	# Avoid test failures with unittest2 and Python 3.
	sed -e "s/from unittest2 import \*/raise ImportError/" -i django/utils/unittest/__init__.py
	distutils-r1_python_prepare_all
}

python_compile_all() {
	if use doc; then
		emake -C docs html
	fi
}

python_test() {
	# Tests have non-standard assumptions about PYTHONPATH,
	# and don't work with ${BUILD_DIR}/lib.
	# https://code.djangoproject.com/ticket/20514
	# https://code.djangoproject.com/ticket/21093
	PYTHONPATH=. \
		"${PYTHON}" tests/runtests.py --settings=test_sqlite -v1 \
		|| die "Tests fail with ${EPYTHON}"
}

src_test() {
	# Port conflict in django.test.testcases.LiveServerTestCase.
	# Several other races with temp files.
	DISTUTILS_NO_PARALLEL_BUILD=1 distutils-r1_src_test
}

src_install() {
	distutils-r1_src_install
	webapp_src_install
}

python_install_all() {
	newbashcomp extras/django_bash_completion ${PN}

	if use doc; then
		rm -fr docs/_build/html/_sources
		local HTML_DOCS=( docs/_build/html/. )
	fi

	insinto "${MY_HTDOCSDIR#${EPREFIX}}"
	doins -r django/contrib/admin/static/admin/.
	distutils-r1_python_install_all
}

pkg_postinst() {
	elog "A copy of the admin media is available to webapp-config for installation in a"
	elog "webroot, as well as the traditional location in python's site-packages dir"
	elog "for easy development."
	webapp_pkg_postinst
}
