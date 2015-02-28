# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/sfc/sfc-0.018.ebuild,v 1.2 2014/08/10 21:11:52 slyfox Exp $

EAPI="4"

inherit autotools

DESCRIPTION="SoundFontCombi is an opensource software pseudo synthesizer"
HOMEPAGE="http://personal.telefonica.terra.es/web/soudfontcombi/"
SRC_URI="http://personal.telefonica.terra.es/web/soudfontcombi/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

RDEPEND="
	media-libs/alsa-lib
	x11-libs/fltk:1"
DEPEND="${RDEPEND}"

src_prepare() {
	sed -i -e "/CXXFLAGS/s:-O3:${CXXFLAGS}:" configure.in
	eautoreconf
}
