# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/setuptools/setuptools-0.8-r1.ebuild,v 1.14 2014/03/31 20:30:56 mgorny Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3} pypy pypy2_0 )

inherit distutils-r1

DESCRIPTION="a collection of extensions to Distutils"
HOMEPAGE="http://pypi.python.org/pypi/setuptools"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS="alpha amd64 arm arm64 hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~arm-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

# Force in-source build because build system modifies sources.
DISTUTILS_IN_SOURCE_BUILD=1

DOCS=( README.txt docs/{easy_install.txt,pkg_resources.txt,setuptools.txt} )

python_prepare_all() {
	local PATCHES=(
		"${FILESDIR}"/${PN}-0.9.8-install_scripts-overwrite.patch
	)

	# Disable tests requiring network connection.
	rm -f setuptools/tests/test_packageindex.py

	distutils-r1_python_prepare_all
}

python_test() {
	# Fails test_setup_requires under python2.5; probably a distutils bug
	esetup.py test
}

python_install() {
	export DISTRIBUTE_DISABLE_VERSIONED_EASY_INSTALL_SCRIPT=1
	distutils-r1_python_install
}
