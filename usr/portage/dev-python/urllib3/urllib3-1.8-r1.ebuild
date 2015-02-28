# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/urllib3/urllib3-1.8-r1.ebuild,v 1.7 2014/05/06 04:44:23 radhermit Exp $

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3} pypy pypy2_0 )

inherit distutils-r1

DESCRIPTION="HTTP library with thread-safe connection pooling, file post, and more"
HOMEPAGE="https://github.com/shazow/urllib3"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="test"

RDEPEND="dev-python/six[${PYTHON_USEDEP}]
	$(python_gen_cond_dep \
		'dev-python/backports-ssl-match-hostname[${PYTHON_USEDEP}]' \
		'python2*' pypy pypy2_0)"
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	test? (
		>=www-servers/tornado-2.4.1[${PYTHON_USEDEP}]
		dev-python/mock[${PYTHON_USEDEP}]
		dev-python/nose[${PYTHON_USEDEP}]
	)"

python_prepare_all() {
	# Replace bundled copy of dev-python/six
	cat > urllib3/packages/six.py <<-EOF
		from __future__ import absolute_import
		from six import *
	EOF

	sed -i -e "s/'dummyserver',//" setup.py || die
	sed -e 's:cover-min-percentage = 100::' -i setup.cfg || die

	distutils-r1_python_prepare_all
}

python_test() {
	nosetests -v || die "Tests fail with ${EPYTHON}"
}
