# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/qbittorrent/qbittorrent-9999.ebuild,v 1.16 2014/05/24 22:53:34 pesa Exp $

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7} )

inherit python-r1 qt4-r2 git-r3

DESCRIPTION="BitTorrent client in C++ and Qt"
HOMEPAGE="http://www.qbittorrent.org/"
EGIT_REPO_URI="https://github.com/${PN}/qBittorrent.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

IUSE="dbus debug geoip +X"

# geoip and python are runtime deps only (see INSTALL file)
CDEPEND="
	dev-libs/boost:=
	dev-qt/qtcore:4
	>=dev-qt/qtsingleapplication-2.6.1_p20130904-r1[X?]
	>=net-libs/rb_libtorrent-0.16.10
	dbus? ( dev-qt/qtdbus:4 )
	X? ( dev-qt/qtgui:4 )
"
DEPEND="${CDEPEND}
	virtual/pkgconfig
"
RDEPEND="${CDEPEND}
	${PYTHON_DEPS}
	geoip? ( dev-libs/geoip )
"

DOCS=(AUTHORS Changelog README TODO)

src_configure() {
	# Custom configure script, econf fails
	local myconf=(
		./configure
		--prefix="${EPREFIX}/usr"
		--with-libboost-inc="${EPREFIX}/usr/include/boost"
		--with-qtsingleapplication=system
		$(use dbus  || echo --disable-qt-dbus)
		$(use debug && echo --enable-debug)
		$(use geoip || echo --disable-geoip-database)
		$(use X     || echo --disable-gui)
	)

	echo "${myconf[@]}"
	"${myconf[@]}" || die "configure failed"
	eqmake4
}
