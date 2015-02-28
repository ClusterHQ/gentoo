# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/gnome-weather/gnome-weather-3.10.1.ebuild,v 1.4 2014/03/09 10:50:50 pacho Exp $

EAPI="5"
GCONF_DEBUG="no"

inherit eutils gnome2

DESCRIPTION="A weather application for GNOME"
HOMEPAGE="https://wiki.gnome.org/Design/Apps/Weather"

LICENSE="GPL-2+ LGPL-2+ MIT CC-BY-3.0 CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

RDEPEND="
	dev-libs/gjs
	>=dev-libs/glib-2.32:2
	>=dev-libs/gobject-introspection-1.35.9
	>=dev-libs/libgweather-3.9.5
	>=x11-libs/gtk+-3.9.4:3
"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.26
	virtual/pkgconfig
"
