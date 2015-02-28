# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-i18n/pology/pology-9999.ebuild,v 1.4 2014/08/10 17:52:30 slyfox Exp $

EAPI=4

ESVN_REPO_URI="svn://anonsvn.kde.org/home/kde/trunk/l10n-support/pology"
PYTHON_DEPEND="2:2.7"

[[ ${PV} == 9999 ]] && VCS_ECLASS="subversion"

inherit python cmake-utils bash-completion-r1 ${VCS_ECLASS}
unset VCS_ECLASS

DESCRIPTION="A framework for custom processing of PO files"
HOMEPAGE="http://pology.nedohodnik.net"
[[ ${PV} == 9999 ]] || SRC_URI="http://pology.nedohodnik.net//release/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
[[ ${PV} == 9999 ]] || KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-libs/libxslt
	dev-libs/libxml2
	dev-python/dbus-python
	sys-devel/gettext
"
DEPEND="${RDEPEND}
	app-text/docbook-xsl-stylesheets
	app-text/docbook-xml-dtd:4.5
	dev-python/epydoc
"

# Magic on python parsing makes it impossible to make it parallel safe
MAKEOPTS+=" -j1"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	python_convert_shebangs -r 2 .
}

src_install() {
	cmake-utils_src_install

	dosym /usr/share/pology/syntax/kate/synder.xml /usr/share/apps/katepart/syntax/synder.xml

	newbashcomp "${ED}"/usr/share/pology/completion/bash/pology ${PN}

	einfo "You should also consider following packages to install:"
	einfo "    app-text/aspell"
	einfo "    app-text/hunspell"
	einfo "    dev-vcs/git"
	einfo "    dev-vcs/subversion"
	einfo "    sci-misc/apertium"
}
