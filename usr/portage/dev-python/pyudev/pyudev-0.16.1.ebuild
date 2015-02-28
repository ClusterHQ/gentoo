# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyudev/pyudev-0.16.1.ebuild,v 1.6 2013/10/04 16:17:10 vapier Exp $

EAPI="4"
PYTHON_DEPEND="*:2.6"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.[5] *-jython"
DISTUTILS_SRC_TEST="py.test"

inherit distutils

DESCRIPTION="Python binding to libudev"
HOMEPAGE="http://packages.python.org/pyudev/ http://pypi.python.org/pypi/pyudev"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="pygobject pyqt4 pyside"

RDEPEND="virtual/udev
	pygobject? ( dev-python/pygobject:2 )
	pyqt4? ( dev-python/PyQt4 )
	pyside? ( dev-python/pyside )"
DEPEND="${RDEPEND}
	dev-python/setuptools
	test? ( dev-python/mock )"

DOCS="CHANGES.rst README.rst"

src_prepare() {
	distutils_src_prepare

	# tests are known to pass then fail on alternate runs
	# tests: fix run_path
	sed -i -e "s|== \('/run/udev'\)|in (\1,'/dev/.udev')|g" tests/test_core.py

	if ! use pygobject; then
		rm -f pyudev/glib.py
		sed -i -e "s|[, ]*GlibBinding()||g" tests/test_observer.py
	fi
	if ! use pyqt4; then
		rm -f pyudev/pyqt4.py
		sed -i -e "s|Qt4Binding('PyQt4')[, ]*||g" tests/test_observer.py
	fi
	if ! use pyside; then
		rm -f pyudev/pyside.py
		sed -i -e "s|Qt4Binding('PySide')[, ]*||g" tests/test_observer.py
	fi
	if ! use pyqt4 && ! use pyside; then
		rm -f pyudev/_qt_base.py
	fi
	if ! use pyqt4 && ! use pyside && ! use pygobject; then
		rm -f tests/test_observer.py
	fi

	ewarn "if your PORTAGE_TMPDIR is longer in length then "/var/tmp/", change it to /var/tmp to ensure tests will pass"
}
