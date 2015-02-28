# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/urllib3/urllib3-1.5-r1.ebuild,v 1.1 2013/03/25 16:41:11 prometheanfire Exp $

EAPI="5"
PYTHON_COMPAT=( python2_6 python2_7 )

inherit distutils-r1

DESCRIPTION="HTTP library with thread-safe connection pooling, file post, and more"
HOMEPAGE="https://github.com/shazow/urllib3"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="test"

RDEPEND="dev-python/six[${PYTHON_USEDEP}]"
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
		test? ( www-servers/tornado[${PYTHON_USEDEP}]
				dev-python/nose[${PYTHON_USEDEP}] )"

python_prepare() {
	# Replace bundled copy of dev-python/six
	cat > urllib3/packages/six.py <<-EOF
	from __future__ import absolute_import
	from six import *
	EOF

	sed -i -e "s/'dummyserver',//" setup.py || die

	distutils-r1_python_prepare
}

python_test() {
	nosetests || die "Tests fail with ${EPYTHON}"
}
