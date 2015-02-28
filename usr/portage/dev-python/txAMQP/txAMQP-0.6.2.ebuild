# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/txAMQP/txAMQP-0.6.2.ebuild,v 1.5 2014/03/31 21:19:31 mgorny Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3} pypy pypy2_0 )
inherit distutils-r1

DESCRIPTION="Python library for communicating with AMQP peers using Twisted"
HOMEPAGE="https://launchpad.net/txamqp"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="dev-python/twisted-core"
