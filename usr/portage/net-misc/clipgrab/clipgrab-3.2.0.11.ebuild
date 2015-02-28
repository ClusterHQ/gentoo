# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/clipgrab/clipgrab-3.2.0.11.ebuild,v 1.3 2013/08/11 22:57:48 aballier Exp $

EAPI=4

inherit qt4-r2 eutils

DESCRIPTION="Download from various internet video services like Youtube etc."
HOMEPAGE="http://clipgrab.de/en"
SRC_URI="http://${PN}.de/download/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-qt/qtwebkit:4"
# does not work with libav #474368
RDEPEND="${DEPEND}
	media-video/ffmpeg:0"

PATCHES=(
	"${FILESDIR}/${PN}-3.2.0.10-obey.patch"
)

src_install() {
	dobin ${PN}

	newicon icon.png ${PN}.png
	make_desktop_entry clipgrab Clipgrab "" "Qt;Video;AudioVideo;"
}
