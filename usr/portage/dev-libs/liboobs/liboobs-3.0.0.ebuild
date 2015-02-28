# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/liboobs/liboobs-3.0.0.ebuild,v 1.8 2014/08/10 20:36:58 slyfox Exp $

EAPI="3"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="Liboobs is a wrapping library to the System Tools Backends"
HOMEPAGE="http://library.gnome.org/devel/liboobs/stable/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm ia64 ppc sparc x86"
IUSE="doc"

# FIXME: check if policykit should be checked in configure ?
RDEPEND=">=dev-libs/glib-2.14:2
	>=dev-libs/dbus-glib-0.70
	>=app-admin/system-tools-backends-2.10.1"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( >=dev-util/gtk-doc-1.9 )"

pkg_setup() {
	G2CONF="${G2CONF} --without-hal --disable-static"
	DOCS="AUTHORS ChangeLog NEWS README"
}
