# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/crumbs/crumbs-9999.ebuild,v 1.3 2014/09/02 21:32:05 alunduil Exp $

EAPI=5
PYTHON_COMPAT=( python2_7 python3_2 python3_3 )

inherit distutils-r1 git-2

EGIT_REPO_URI="git://github.com/alunduil/crumbs.git"

DESCRIPTION="Generalized all-in-one parameters module"
HOMEPAGE="https://github.com/alunduil/crumbs"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="inotify test"

CDEPEND="inotify? ( dev-python/pyinotify[${PYTHON_USEDEP}] )"
DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? (
		${CDEPEND}
		dev-python/coverage[${PYTHON_USEDEP}]
		dev-python/mock[${PYTHON_USEDEP}]
		dev-python/nose[${PYTHON_USEDEP}]
	)
"
RDEPEND="${CDEPEND}"

python_test() {
	nosetests || die "Tests failed on ${EPYTHON}"
}
