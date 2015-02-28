# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/bijiben/bijiben-3.10.2.ebuild,v 1.5 2014/03/09 11:53:54 pacho Exp $

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="Note editor designed to remain simple to use"
HOMEPAGE="http://live.gnome.org/Bijiben"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	>=app-misc/tracker-0.16:=
	>=dev-libs/glib-2.28:2
	dev-libs/libxml2
	gnome-extra/zeitgeist
	media-libs/clutter-gtk:1.0
	net-libs/gnome-online-accounts
	net-libs/webkit-gtk:3
	sys-apps/util-linux
	>=x11-libs/gtk+-3.9.3:3
"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35.0
	sys-devel/gettext
	virtual/pkgconfig
"
#	app-text/yelp-tools

src_configure() {
	gnome2_src_configure ITSTOOL="$(type -P true)"
}
