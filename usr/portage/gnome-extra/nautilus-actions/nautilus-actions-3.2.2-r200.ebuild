# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/nautilus-actions/nautilus-actions-3.2.2-r200.ebuild,v 1.4 2013/12/08 18:55:52 pacho Exp $

EAPI="4"

GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="Configures programs to be launched when files are selected in Nautilus"
HOMEPAGE="http://www.nautilus-actions.org/"

LICENSE="GPL-2 FDL-1.3"
SLOT="2"
KEYWORDS="amd64 x86"
IUSE="deprecated"

RDEPEND=">=dev-libs/glib-2.30:2
	>=dev-libs/libxml2-2.6:2
	dev-libs/libunique:1
	>=gnome-base/libgtop-2.23.1:2
	>=gnome-base/nautilus-2.16
	<gnome-base/nautilus-2.90
	sys-apps/util-linux
	x11-libs/gdk-pixbuf:2
	>=x11-libs/gtk+-2.20:2
	x11-libs/libICE
	>=x11-libs/libSM-1

	!gnome-extra/nautilus-actions:3"
DEPEND="${RDEPEND}
	dev-util/gdbus-codegen
	>=dev-util/intltool-0.35.5
	virtual/pkgconfig"

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable deprecated)
		--disable-gconf
		--with-gtk=2"
}

src_prepare() {
	# install docs in /usr/share/doc/${PF}, not ${P}
	sed -i -e "s:/doc/@PACKAGE@-@VERSION@:/doc/${PF}:g" \
		Makefile.{am,in} \
		docs/Makefile.{am,in} \
		docs/nact/Makefile.{am,in} || die
	gnome2_src_prepare
}

src_install() {
	gnome2_src_install
	# Do not install COPYING
	rm -v "${ED}usr/share/doc/${PF}"/COPYING* || die
}
