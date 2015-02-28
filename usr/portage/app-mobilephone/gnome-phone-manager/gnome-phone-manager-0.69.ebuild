# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-mobilephone/gnome-phone-manager/gnome-phone-manager-0.69.ebuild,v 1.5 2014/02/22 21:00:57 pacho Exp $

EAPI="5"
GCONF_DEBUG="yes"
GNOME2_LA_PUNT="yes"

inherit autotools eutils gnome2

DESCRIPTION="A program created to allow you to control aspects of your mobile phone from your GNOME desktop"
HOMEPAGE="http://live.gnome.org/PhoneManager"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc x86"
IUSE="gnome"
# telepathy support is considered experimental

RDEPEND=">=dev-libs/glib-2.31.0:2
	>=x11-libs/gtk+-3:3
	>=gnome-base/orbit-2
	>=gnome-base/gconf-2:2
	>=gnome-extra/evolution-data-server-3.6
	media-libs/libcanberra[gtk3]
	>=app-mobilephone/gnokii-0.6.28[bluetooth]
	net-wireless/bluez
	dev-libs/dbus-glib
	dev-libs/openobex
	media-libs/libcanberra[gtk]
	>=x11-themes/gnome-icon-theme-2.19.1
	>=net-wireless/gnome-bluetooth-3.3:2"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35.5
	virtual/pkgconfig
	gnome-base/gnome-common"
# gnome-common needed for eautoreconf

src_prepare() {
	# Fix eds-3.6 building, upstream bug #680927
	epatch "${FILESDIR}"/0001-Adapt-to-Evolution-Data-Server-API-changes.patch

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		$(use_enable gnome bluetooth-plugin) \
		--disable-telepathy \
		--disable-static
}
