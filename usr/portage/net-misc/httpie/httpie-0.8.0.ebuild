# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/httpie/httpie-0.8.0.ebuild,v 1.2 2014/07/06 12:54:51 mgorny Exp $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3} )

inherit distutils-r1

DESCRIPTION="A CLI, cURL-like tool for humans"
HOMEPAGE="http://httpie.org/ http://pypi.python.org/pypi/httpie"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	>=dev-python/requests-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/pygments-1.5[${PYTHON_USEDEP}]"
