# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/alglib/alglib-3.7.0.ebuild,v 1.2 2014/01/19 09:38:08 pacho Exp $

EAPI=5

inherit cmake-utils

DESCRIPTION="Numerical analysis and data processing library"
HOMEPAGE="http://www.alglib.net/"
SRC_URI="http://www.alglib.net/translator/re/${P}.cpp.tgz"

SLOT="0"
LICENSE="GPL-2+"
KEYWORDS="amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
"

S="${WORKDIR}"/cpp/

src_prepare() {
	cp "${FILESDIR}"/CMakeLists.txt . || die
	cmake-utils_src_prepare
}
