# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/python-gnupg/python-gnupg-0.3.6.ebuild,v 1.3 2014/06/25 07:30:40 idella4 Exp $

EAPI=5
PYTHON_COMPAT=( python{2_7,3_2,3_3,3_4} pypy )

inherit distutils-r1

DESCRIPTION="Python wrapper for GNU Privacy Guard"
HOMEPAGE="http://pythonhosted.org/python-gnupg/ https://bitbucket.org/vinay.sajip/python-gnupg"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="app-crypt/gnupg"

PATCHES=( "${FILESDIR}"/${P}-skip-search-keys-tests.patch )

python_test() {
	cd "${BUILD_DIR}" || die
	"${PYTHON}" "${S}"/test_gnupg.py || die "Tests fail with ${EPYTHON}"
}
