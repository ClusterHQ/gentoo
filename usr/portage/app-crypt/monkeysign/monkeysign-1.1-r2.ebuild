# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/monkeysign/monkeysign-1.1-r2.ebuild,v 1.1 2014/07/29 11:07:53 k_f Exp $

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1

DESCRIPTION="A user-friendly commandline tool to sign OpenGPG keys"
HOMEPAGE="http://web.monkeysphere.info/monkeysign/"

SRC_URI="mirror://debian/pool/main/m/monkeysign/monkeysign_${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="dev-python/pygtk:2[${PYTHON_USEDEP}]
	media-gfx/zbar:0=[python,gtk,imagemagick]
	media-gfx/qrencode-python[${PYTHON_USEDEP}]
	virtual/python-imaging[${PYTHON_USEDEP}]"

DEPEND="dev-python/docutils[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	${CDEPEND}"

RDEPEND="app-crypt/gnupg
	virtual/mta
	${CDEPEND}"

PATCHES=("${FILESDIR}/${P}-basename.patch"
	 "${FILESDIR}/${P}-rst2s5.patch"
	)

python_install_all()
{
	distutils-r1_python_install_all
	domenu "${FILESDIR}/monkeysign.desktop"
}
