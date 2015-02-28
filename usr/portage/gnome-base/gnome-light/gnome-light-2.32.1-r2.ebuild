# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-light/gnome-light-2.32.1-r2.ebuild,v 1.10 2012/11/05 21:38:52 ulm Exp $

EAPI="4"

S=${WORKDIR}
DESCRIPTION="Meta package for the GNOME desktop, merge this package to install"
HOMEPAGE="http://www.gnome.org/"
LICENSE="metapackage"
SLOT="2.0"
IUSE="+automount"

# when unmasking for an arch
# double check none of the deps are still masked !
KEYWORDS="alpha amd64 arm ia64 ppc ppc64 sparc x86 ~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"

#  Note to developers:
#  This is a wrapper for the 'light' Gnome2 desktop,
#  This should only consist of the bare minimum of libs/apps needed
#  It is basicly the gnome-base/gnome without all extra apps

#  This is currently in it's test phase, if you feel like some dep
#  should be added or removed from this pack file a bug to
#  gnome@gentoo.org on bugs.gentoo.org

#	>=media-gfx/eog-2.30.2

RDEPEND="!<x11-libs/gtk+-3.2.4-r1:3
	!gnome-base/gnome

	>=dev-libs/glib-2.26.1:2
	>=x11-libs/gtk+-2.22.1-r1:2
	>=x11-libs/gdk-pixbuf-2.22.1:2
	>=dev-libs/atk-1.32.0
	>=x11-libs/pango-1.28.3

	>=gnome-base/orbit-2.14.19:2

	>=x11-libs/libwnck-2.30.6:1
	>=x11-wm/metacity-2.30.3

	>=gnome-base/gconf-2.32.0-r1:2
	>=gnome-base/dconf-0.5.1-r2

	>=gnome-base/libbonobo-2.24.3
	>=gnome-base/libbonoboui-2.24.4
	>=gnome-base/libgnome-2.32.0
	>=gnome-base/libgnomecanvas-2.30.2
	>=gnome-base/libglade-2.6.4:2.0

	>=gnome-base/gnome-settings-daemon-2.32.1
	>=gnome-base/gnome-control-center-2.32.0

	>=gnome-base/nautilus-2.32.1

	>=gnome-base/gnome-desktop-2.32.1:2
	>=gnome-base/gnome-session-2.32.1
	>=gnome-base/gnome-panel-2.32.1

	>=x11-themes/gnome-icon-theme-2.31.0
	>=x11-themes/gnome-themes-2.32.1-r1
	>=x11-themes/gnome-themes-standard-3.0.2

	>=x11-terms/gnome-terminal-2.32.1

	>=gnome-base/librsvg-2.32.1:2

	>=gnome-extra/yelp-2.30.2"
DEPEND=""
PDEPEND=">=gnome-base/gvfs-1.6.6
	automount? ( || ( >=gnome-base/gvfs-1.6.6[gdu] >=gnome-base/gvfs-1.6.6[udisks] ) )"

pkg_postinst () {
# FIXME: Rephrase to teach about using different WMs instead, as metacity is the default anyway
# FIXME: but first check WINDOW_MANAGER is still honored in 2.24. gnome-session-2.24 might have lost
# FIXME: support for it, but we don't ship with gnome-session-2.24 yet
#	elog "Note that to change windowmanager to metacity do: "
#	elog " export WINDOW_MANAGER=\"/usr/bin/metacity\""
#	elog "of course this works for all other window managers as well"
#	elog

	elog
	elog "Use gnome-base/gnome for the full GNOME Desktop"
	elog "as released by the GNOME team."
}
