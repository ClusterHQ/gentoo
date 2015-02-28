# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/jsmath/jsmath-1.0.ebuild,v 1.2 2009/11/17 06:42:38 bicatali Exp $

inherit font

MYPN=TeX-fonts-linux

DESCRIPTION="Raster fonts for jsmath"
HOMEPAGE="http://www.math.union.edu/~dpvc/jsMath/"
SRC_URI="http://www.math.union.edu/~dpvc/jsMath/download/${MYPN}.tgz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${MYPN}"
FONT_S="${S}"
FONT_PN="jsMath"
FONT_SUFFIX="ttf"
