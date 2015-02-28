# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/otter/otter-0.9.02.ebuild,v 1.1 2014/09/13 09:18:31 jer Exp $

EAPI=5
WANT_CMAKE="always"
inherit eutils cmake-utils

DESCRIPTION="Project aiming to recreate classic Opera (12.x) UI using Qt5"
HOMEPAGE="http://otter-browser.org/"
SRC_URI="https://github.com/Emdek/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtprintsupport:5
	dev-qt/qtscript:5
	dev-qt/qtsql:5
	dev-qt/qtwebkit:5[widgets]
	dev-qt/qtwidgets:5
"
RDEPEND="
	${DEPEND}
"
DOCS=( CHANGELOG HACKING TODO )

src_prepare() {
	sed -i -e 's|Application;||g' ${PN}-browser.desktop || die

	if [[ -n ${LINGUAS} ]]; then
		local lingua
		for lingua in resources/translations/*.qm; do
			lingua=$(basename ${lingua})
			lingua=${lingua/otter-browser_/}
			lingua=${lingua/.qm/}
			if ! has ${lingua} ${LINGUAS}; then
				rm resources/translations/otter-browser_${lingua}.qm || die
			fi
		done
	fi
}

src_install() {
	cmake-utils_src_install
	domenu ${PN}-browser.desktop
}
