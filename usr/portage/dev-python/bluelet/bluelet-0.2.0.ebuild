# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/bluelet/bluelet-0.2.0.ebuild,v 1.3 2013/09/10 03:04:48 patrick Exp $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3} )

inherit distutils-r1

DESCRIPTION="Module for pure Python asynchronous I/O using coroutines"
HOMEPAGE="http://pypi.python.org/pypi/bluelet"
SRC_URI="https://github.com/sampsyo/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples"

DEPEND=""
RDEPEND="${DEPEND}"

python_install_all() {
	if use examples; then
		docompress -x usr/share/doc/${P}/demo
		dodoc -r demo/
	fi
}
