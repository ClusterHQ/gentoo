# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/folks/folks-0.9.8.ebuild,v 1.1 2014/09/02 10:38:39 pacho Exp $

EAPI="5"
GCONF_DEBUG="yes"
VALA_MIN_API_VERSION="0.22"
VALA_USE_DEPEND="vapigen"

inherit gnome2 vala virtualx

DESCRIPTION="Library for aggregating people from multiple sources"
HOMEPAGE="https://wiki.gnome.org/Projects/Folks"

LICENSE="LGPL-2.1+"
SLOT="0/25" # subslot = libfolks soname version
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-linux"
# TODO: --enable-profiling
# Vala isn't really optional, https://bugzilla.gnome.org/show_bug.cgi?id=701099
IUSE="bluetooth eds socialweb +telepathy test tracker utils zeitgeist"
REQUIRED_USE="bluetooth? ( eds )"

COMMON_DEPEND="
	$(vala_depend)
	>=dev-libs/glib-2.38.2:2
	dev-libs/dbus-glib
	>=dev-libs/libgee-0.10:0.8[introspection]
	dev-libs/libxml2
	sys-libs/ncurses:=
	sys-libs/readline:=

	bluetooth? ( >=net-wireless/bluez-5 )
	eds? ( >=gnome-extra/evolution-data-server-3.8:=[vala] )
	socialweb? ( >=net-libs/libsocialweb-0.25.20 )
	telepathy? ( >=net-libs/telepathy-glib-0.19[vala] )
	tracker? ( >=app-misc/tracker-1:0= )
	zeitgeist? ( >=gnome-extra/zeitgeist-0.9.14 )
"
# telepathy-mission-control needed at runtime; it is used by the telepathy
# backend via telepathy-glib's AccountManager binding.
RDEPEND="${COMMON_DEPEND}
	net-im/telepathy-mission-control
"
# folks socialweb backend requires that libsocialweb be built with USE=vala,
# even when building folks with --disable-vala.
#
# FIXME:
# test? ( bluetooth? ( dbusmock is missing in the tree ) )
DEPEND="${COMMON_DEPEND}
	>=dev-libs/gobject-introspection-1.30
	>=dev-util/intltool-0.50.0
	sys-devel/gettext
	virtual/pkgconfig

	socialweb? ( >=net-libs/libsocialweb-0.25.15[vala] )
	test? ( sys-apps/dbus
		bluetooth? (
			>=gnome-extra/evolution-data-server-3.9.1
			>=dev-libs/glib-2.39.2 ) )
	!<dev-lang/vala-0.22.1:0.22
"

src_prepare() {
	# Allow building against tracker-1.0
	# https://bugzilla.gnome.org/show_bug.cgi?id=728520
	sed -e 's/\(TRACKER_SPARQL_MAJOR\)=0.16/\1=1.0/' \
		-i configure{.ac,} || die

	vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	# Rebuilding docs needs valadoc, which has no release
	gnome2_src_configure \
		$(use_enable bluetooth bluez-backend) \
		$(use_enable eds eds-backend) \
		$(use_enable eds ofono-backend) \
		$(use_enable socialweb libsocialweb-backend) \
		$(use_enable telepathy telepathy-backend) \
		$(use_enable tracker tracker-backend) \
		$(use_enable utils inspect-tool) \
		$(use_enable test tests) \
		$(use_enable zeitgeist) \
		--enable-vala \
		--enable-import-tool \
		--disable-docs \
		--disable-fatal-warnings
}

src_test() {
	dbus-launch Xemake check
}
