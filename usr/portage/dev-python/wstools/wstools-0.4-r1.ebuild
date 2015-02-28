# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/wstools/wstools-0.4-r1.ebuild,v 1.3 2014/03/31 20:53:45 mgorny Exp $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} pypy pypy2_0 )
PYTHON_REQ_USE="xml(+)"

inherit distutils-r1

DESCRIPTION="WSDL parsing services package for Web Services for Python"
HOMEPAGE="https://github.com/kiorky/wstools http://pypi.python.org/pypi/wstools"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-macos"
IUSE=""

RDEPEND=""
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
