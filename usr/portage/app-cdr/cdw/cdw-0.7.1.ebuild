# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/cdw/cdw-0.7.1.ebuild,v 1.4 2012/06/07 21:50:59 ranger Exp $

EAPI=2
inherit autotools flag-o-matic eutils

DESCRIPTION="An ncurses based console frontend for cdrtools and dvd+rw-tools"
HOMEPAGE="http://cdw.sourceforge.net"
SRC_URI="mirror://sourceforge/cdw/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE=""

DEPEND="virtual/cdrtools
	app-cdr/dvd+rw-tools
	dev-libs/libburn
	dev-libs/libcdio[-minimal]
	sys-libs/ncurses[unicode]"

src_prepare() {
	epatch "${FILESDIR}"/${P}-asneeded.patch
	rm -f missing
	eautoreconf
	strip-flags
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README THANKS cdw.conf
}
