# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/gnome-power-manager/gnome-power-manager-3.10.1.ebuild,v 1.6 2014/05/31 22:24:48 ssuominen Exp $

EAPI="5"
GCONF_DEBUG="no"

inherit eutils gnome2 virtualx

DESCRIPTION="GNOME power management service"
HOMEPAGE="http://projects.gnome.org/gnome-power-manager/"

LICENSE="GPL-2"
SLOT="0"
IUSE="test"
KEYWORDS="~alpha amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc x86 ~x86-fbsd"

COMMON_DEPEND="
	>=dev-libs/glib-2.36:2
	>=x11-libs/gtk+-3.3.8:3
	>=x11-libs/cairo-1
	|| ( <sys-power/upower-0.99 sys-power/upower-pm-utils )
"
RDEPEND="${COMMON_DEPEND}
	x11-themes/gnome-icon-theme-symbolic
"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-sgml-dtd:4.1
	app-text/docbook-sgml-utils
	>=app-text/gnome-doc-utils-0.3.2
	app-text/scrollkeeper
	>=dev-util/intltool-0.35
	sys-devel/gettext
	x11-proto/randrproto
	virtual/pkgconfig
	test? ( sys-apps/dbus )
"

# docbook-sgml-utils and docbook-sgml-dtd-4.1 used for creating man pages
# (files under ${S}/man).
# docbook-xml-dtd-4.4 and -4.1.2 are used by the xml files under ${S}/docs.

src_prepare() {
	# Drop debugger CFLAGS from configure
	# Touch configure.ac only if running eautoreconf, otherwise
	# maintainer mode gets triggered -- even if the order is correct
	sed -e 's:^CPPFLAGS="$CPPFLAGS -g"$::g' \
		-i configure || die "debugger sed failed"
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		$(use_enable test tests) \
		--enable-compile-warnings=minimum
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	Xemake check
}
