# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/webapp-config/webapp-config-1.50.19.ebuild,v 1.4 2012/06/28 23:28:24 blueness Exp $

EAPI="3"

PYTHON_DEPEND="2:2.6"
SUPPORT_PYTHON_ABIS="1"

inherit distutils eutils prefix

DESCRIPTION="Gentoo's installer for web-based applications"
HOMEPAGE="http://sourceforge.net/projects/webapp-config/"
SRC_URI="http://dev.gentoo.org/~blueness/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE=""

DEPEND="app-text/xmlto"
RDEPEND=""
RESTRICT_PYTHON_ABIS="2.5 3.*"

PYTHON_MODNAME="WebappConfig"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.50.18-prefix.patch

	eprefixify \
		WebappConfig/config.py \
		WebappConfig/db.py \
		WebappConfig/sandbox.py \
		WebappConfig/wrapper.py \
		config/webapp-config
}

src_compile() {
	distutils_src_compile
	#parallel build fixed in next release
	emake -j1 -C doc/
}

src_install() {
	# According to this discussion:
	# http://mail.python.org/pipermail/distutils-sig/2004-February/003713.html
	# distutils does not provide for specifying two different script install
	# locations. Since we only install one script here the following should
	# be ok
	distutils_src_install --install-scripts="${EPREFIX}/usr/sbin"

	insinto /etc/vhosts
	doins config/webapp-config

	keepdir /usr/share/webapps
	keepdir /var/db/webapps

	dodoc AUTHORS TODO
	doman doc/*.[58]
	dohtml doc/*.[58].html
}

src_test() {
	testing() {
		PYTHONPATH="." "$(PYTHON)" WebappConfig/tests/dtest.py
	}
	python_execute_function testing
}

pkg_postinst() {
	distutils_pkg_postinst

	elog "Now that you have upgraded webapp-config, you **must** update your"
	elog "config files in /etc/vhosts/webapp-config before you emerge any"
	elog "packages that use webapp-config."
}
