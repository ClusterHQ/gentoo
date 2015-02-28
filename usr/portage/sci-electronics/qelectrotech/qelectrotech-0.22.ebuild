# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-electronics/qelectrotech/qelectrotech-0.22.ebuild,v 1.4 2013/03/02 23:20:02 hwoarang Exp $

EAPI="2"

inherit qt4-r2

MY_P="${PN}-${PV}-src"

DESCRIPTION="Qt4 application to design electric diagrams"
HOMEPAGE="http://www.qt-apps.org/content/show.php?content=90198"
SRC_URI="http://download.tuxfamily.org/qet/tags/20100313/${MY_P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="debug doc"

RDEPEND="dev-qt/qtgui:4
	dev-qt/qtsvg:4"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

S="${WORKDIR}"/${MY_P}
DOCS="CREDIT ChangeLog README"

PATCHES=( "${FILESDIR}/${PN}-0.2-fix-paths.patch" )

src_install() {
	qt4-r2_src_install
	if use doc; then
		doxygen Doxyfile
		dohtml -r doc/html/* || die "dohtml failed"
	fi
}
