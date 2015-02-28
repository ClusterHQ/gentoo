# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/ocrad/ocrad-0.21.ebuild,v 1.2 2014/02/27 21:14:33 ssuominen Exp $

EAPI=5
inherit unpacker toolchain-funcs

DESCRIPTION="GNU Ocrad is an OCR (Optical Character Recognition) program"
HOMEPAGE="http://www.gnu.org/software/ocrad/ocrad.html"
SRC_URI="http://savannah.nongnu.org/download/ocrad/${P}.tar.lz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

RDEPEND=""
DEPEND="$(unpacker_src_uri_depends)"

DOCS="AUTHORS NEWS README TODO"

src_configure() {
	econf CXX="$(tc-getCXX)" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}"
}

src_install() {
	default
	doman doc/${PN}.1
	doinfo doc/${PN}.info
}
