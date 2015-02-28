# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gupnp-dlna/gupnp-dlna-0.6.6.ebuild,v 1.10 2013/03/30 22:44:35 eva Exp $

EAPI="4"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"

inherit gnome2

DESCRIPTION="Library that provides DLNA-related functionality for MediaServers"
HOMEPAGE="http://gupnp.org/"

LICENSE="LGPL-2"
SLOT="1.0"
KEYWORDS="~alpha amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc x86"
IUSE="doc +introspection"

RDEPEND=">=dev-libs/libxml2-2.5:2
	>=media-libs/gstreamer-0.10.32:0.10
	>=media-libs/gst-plugins-base-0.10.32:0.10[introspection?]
	introspection? ( >=dev-libs/gobject-introspection-0.6.4 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( >=dev-util/gtk-doc-1.10 )"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-static
		$(use_enable introspection)"
	DOCS="AUTHORS ChangeLog NEWS README TODO"
}

src_compile() {
	# gst-plugin-scanner tries to open dri
	unset DISPLAY
	gnome2_src_compile
}
