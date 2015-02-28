# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/pasystray/pasystray-0.1.2.ebuild,v 1.3 2012/05/05 08:45:03 mgorny Exp $

EAPI=4
inherit eutils gnome2-utils

DESCRIPTION="PulseAudio notification area (replacement for the padevchooser)"
HOMEPAGE="http://github.com/christophgysin/pasystray"
SRC_URI="mirror://github/christophgysin/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=media-sound/pulseaudio-1.0[glib,avahi]
	>=net-dns/avahi-0.6
	x11-libs/gtk+:3"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

DOCS="AUTHORS README TODO"

src_prepare() {
	epatch "${FILESDIR}"/${P}-desktop-file-validate.patch
}

pkg_preinst() {	gnome2_icon_savelist; }
pkg_postinst() { gnome2_icon_cache_update; }
pkg_postrm() { gnome2_icon_cache_update; }
