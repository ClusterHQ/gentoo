# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/mate-backgrounds/mate-backgrounds-1.6.1.ebuild,v 1.2 2014/05/04 14:55:42 ago Exp $

EAPI="5"

GCONF_DEBUG="no"

inherit gnome2 versionator

MATE_BRANCH="$(get_version_component_range 1-2)"

SRC_URI="http://pub.mate-desktop.org/releases/${MATE_BRANCH}/${P}.tar.xz"
DESCRIPTION="A set of backgrounds packaged with the MATE desktop"
HOMEPAGE="http://mate-desktop.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"

DEPEND=">=dev-util/intltool-0.35:*
	sys-devel/gettext:*"

DOCS="AUTHORS ChangeLog NEWS README"
