# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/gnome-shell-frippery/gnome-shell-frippery-0.5.1.ebuild,v 1.3 2013/12/08 18:50:45 pacho Exp $

EAPI="5"

DESCRIPTION="Unofficial extension pack providing GNOME 2-like features for GNOME 3"
HOMEPAGE="http://intgat.tigress.co.uk/rmy/extensions/index.html"
SRC_URI="http://intgat.tigress.co.uk/rmy/extensions/${P}.tgz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="app-admin/eselect-gnome-shell-extensions
	>=dev-libs/gjs-1.29
	dev-libs/gobject-introspection
	gnome-base/gnome-menus:3[introspection]
	>=gnome-base/gnome-shell-3.6
	media-libs/clutter:1.0[introspection]
	x11-libs/pango[introspection]"
DEPEND=""

S="${WORKDIR}/.local/share/gnome-shell"

src_install() {
	insinto /usr/share/gnome-shell/extensions
	doins -r extensions/*@*
	dodoc gnome-shell-frippery/{CHANGELOG,README}
}

pkg_postinst() {
	ebegin "Updating list of installed extensions"
	eselect gnome-shell-extensions update
	eend $?
}
