# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/guessit/guessit-9999.ebuild,v 1.3 2014/04/08 17:08:29 maksbotan Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_7,3_3} )
EGIT_REPO_URI="https://github.com/wackou/guessit.git"

inherit distutils-r1 git-r3

DESCRIPTION="library for guessing information from video files"
HOMEPAGE="http://guessit.readthedocs.org https://github.com/wackou/guessit https://pypi.python.org/pypi/guessit"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS=""
IUSE="test"

RDEPEND="
	>=dev-python/babelfish-0.5.1[${PYTHON_USEDEP}]
	>=dev-python/stevedore-0.14[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}
	test? (
		dev-python/pyyaml[${PYTHON_USEDEP}]
	)
	dev-python/setuptools[${PYTHON_USEDEP}]
"

python_test() {
	esetup.py test
}
