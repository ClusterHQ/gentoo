# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/pylize/pylize-1.3b-r1.ebuild,v 1.3 2013/09/05 18:26:42 mgorny Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

DESCRIPTION="Python HTML Slideshow Generator using HTML and CSS"
HOMEPAGE="http://www.chrisarndt.de/en/software/pylize/"
SRC_URI="http://www.chrisarndt.de/en/software/pylize/download/${P}.tar.bz2"

IUSE="doc"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

DEPEND="dev-python/empy[${PYTHON_USEDEP}]
	virtual/python-imaging[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/${PN}-pillow.patch" )

python_configure() {
	set -- "${PYTHON}" configure.py
	echo "$@"
	"$@" || die
}

python_compile_all() {
	if use doc; then
		emake -C doc PYTHON="${PYTHON}" PYLIZE="../pylize" || die
	fi
}

python_install() {
	distutils-r1_python_install
	python_optimize "${ED%/}/usr/share/pylize"
}

python_install_all() {
	local DOCS=( Changelog README README.empy TODO )
	use doc && local HTML_DOCS=( doc/. )
	distutils-r1_python_install_all
}
