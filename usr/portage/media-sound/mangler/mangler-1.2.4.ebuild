# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mangler/mangler-1.2.4.ebuild,v 1.4 2013/01/16 03:45:44 prometheanfire Exp $

EAPI=2

DESCRIPTION="Open source VOIP client capable of connecting to Ventrilo 3.x servers"
HOMEPAGE="http://www.mangler.org/"
SRC_URI="http://www.mangler.org/downloads/${P}.tar.bz2"

LICENSE="GPL-3 LGPL-2.1 ZLIB"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+alsa opus espeak g15 +gsm oss pulseaudio static-libs +speex +xosd"

RDEPEND="dev-cpp/gtkmm:2.4
	gnome-base/librsvg
	>=dev-libs/dbus-glib-0.80
	>=dev-libs/glib-2.20.1:2
	>=x11-libs/gtk+-2.16:2
	x11-libs/libX11
	x11-libs/libXi
	alsa? ( media-libs/alsa-lib )
	opus? ( media-libs/opus )
	espeak? ( app-accessibility/espeak )
	g15? ( app-misc/g15daemon )
	gsm? ( media-sound/gsm )
	pulseaudio? ( >=media-sound/pulseaudio-0.9.14 )
	speex? ( >=media-libs/speex-1.2_rc1 )
	xosd? ( x11-libs/xosd )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_configure() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable gsm) \
		$(use_enable speex) \
		$(use_enable opus) \
		$(use_enable xosd) \
		$(use_enable g15) \
		$(use_enable espeak) \
		$(use_with pulseaudio) \
		$(use_with alsa) \
		$(use_with oss)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog

	find "${D}" -name '*.la' -exec rm -f '{}' +
}
