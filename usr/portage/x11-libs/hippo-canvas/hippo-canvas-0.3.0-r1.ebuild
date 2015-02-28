# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/hippo-canvas/hippo-canvas-0.3.0-r1.ebuild,v 1.9 2013/05/04 23:04:21 elvanor Exp $

EAPI="2"

GCONF_DEBUG="no"
G2PUNT_LA="yes"
PYTHON_DEPEND="python? 2"
inherit eutils gnome2 multilib python

DESCRIPTION="A canvas library based on GTK+ 2, Cairo, and Pango"
HOMEPAGE="http://live.gnome.org/HippoCanvas"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

IUSE="doc python"

RDEPEND=">=dev-libs/glib-2.6:2
	dev-libs/libcroco
	>=x11-libs/gtk+-2.6:2
	x11-libs/pango
	gnome-base/librsvg:2
	python? ( dev-python/pycairo
		dev-python/pygtk:2 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( dev-util/gtk-doc )"

DOCS="AUTHORS README TODO"

pkg_setup() {
	if use python; then
		python_set_active_version 2
	fi
	G2CONF="$(use_enable python)"
}

src_prepare() {
	cd "$S/python"
	epatch "${FILESDIR}/${PN}-python-override.patch"
}

src_configure() {
	econf --disable-static
}

src_install() {
	gnome2_src_install
	if use python; then
		python_clean_installation_image
	fi
	rm "${D}/usr/$(get_libdir)/libhippocanvas-1.la"
}
