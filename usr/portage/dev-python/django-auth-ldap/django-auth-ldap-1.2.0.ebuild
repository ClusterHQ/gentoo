# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/django-auth-ldap/django-auth-ldap-1.2.0.ebuild,v 1.4 2014/07/23 10:37:27 idella4 Exp $

EAPI=5
# Although setup.py claims to support py3, python-ldap does not
PYTHON_COMPAT=( python2_7 pypy )

inherit distutils-r1

DESCRIPTION="Django LDAP authentication backend"
HOMEPAGE="http://pypi.python.org/pypi/django-auth-ldap http://bitbucket.org/psagers/django-auth-ldap/"
SRC_URI="https://www.bitbucket.org.org/psagers/django-auth-ldap/get/80379ce59e6b.zip -> ${P}.zip"
#https://www.bitbucket.org/psagers/django-auth-ldap/get/80379ce59e6b.zip

KEYWORDS="~amd64 ~x86"
IUSE="doc test"

LICENSE="BSD"
SLOT="0"

RDEPEND="dev-python/django[${PYTHON_USEDEP}]
		>=dev-python/python-ldap-2.0[${PYTHON_USEDEP}]"
DEPEND="app-arch/unzip
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? ( ${RDEPEND}
		>=dev-python/mockldap-0.2[${PYTHON_USEDEP}] )
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )"

S="${WORKDIR}"/psagers-${PN}-80379ce59e6b

PATCHES=( "${FILESDIR}"/docs.patch )

python_compile_all() {
	use doc && emake -C docs html
}

python_test() {
	PYTHONPATH=. "${PYTHON}" test/manage.py test
}

python_install_all() {
	use doc && local HTML_DOCS=( docs/build/html/. )
	distutils-r1_python_install_all
}
