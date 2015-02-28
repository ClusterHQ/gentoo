# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-radio/cwdaemon/cwdaemon-0.9.6.ebuild,v 1.2 2012/08/13 18:33:45 tomjbe Exp $

EAPI=4

DESCRIPTION="A morse daemon for the parallel or serial port"
HOMEPAGE="http://cwdaemon.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc ~x86"
IUSE=""

RDEPEND=">=media-radio/unixcw-3.1.1"
DEPEND="$RDEPEND
	virtual/pkgconfig"
