# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/graveman/graveman-0.3.12_p5-r1.ebuild,v 1.9 2012/05/03 07:51:50 jdhore Exp $

EAPI="1"

inherit eutils gnome2

DESCRIPTION="Graphical frontend for cdrecord, mkisofs, readcd and sox using GTK+2"
HOMEPAGE="http://graveman.tuxfamily.org/"
SRC_URI="http://graveman.tuxfamily.org/sources/${PN}-${PV/_p/-}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc ppc64 sparc x86"
IUSE="debug dvdr flac mp3 nls vorbis"

RDEPEND=">=x11-libs/gtk+-2.4:2
	>=dev-libs/glib-2.4:2
	>=gnome-base/libglade-2.4:2.0
	flac? ( media-libs/flac )
	mp3? ( media-libs/libid3tag
		media-libs/libmad
		media-sound/sox )
	vorbis? ( media-libs/libogg
		media-libs/libvorbis
		media-sound/sox )
	virtual/cdrtools
	app-cdr/cdrdao
	media-libs/libmng
	dvdr? ( app-cdr/dvd+rw-tools )
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	virtual/pkgconfig
	dev-util/intltool"

S=${WORKDIR}/${P/_p/-}

DOCS="AUTHORS ChangeLog NEWS README* THANKS"

pkg_setup() {
	G2CONF="${G2CONF} $(use_enable flac) $(use_enable mp3)
	$(use_enable vorbis ogg) $(use_enable debug)"
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/joliet-long.patch \
		"${FILESDIR}"/rename.patch \
		"${FILESDIR}"/desktop-entry.patch

	if use mp3 || use vorbis; then
		epatch "${FILESDIR}"/sox.patch
	fi
}
