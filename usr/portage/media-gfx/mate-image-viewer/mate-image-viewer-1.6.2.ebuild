# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/mate-image-viewer/mate-image-viewer-1.6.2.ebuild,v 1.2 2014/05/04 14:55:19 ago Exp $

EAPI="5"

GCONF_DEBUG="yes"
PYTHON_COMPAT=( python2_{6,7} )

inherit gnome2 python-single-r1 versionator

MATE_BRANCH="$(get_version_component_range 1-2)"

SRC_URI="http://pub.mate-desktop.org/releases/${MATE_BRANCH}/${P}.tar.xz"
DESCRIPTION="The MATE image viewer"
HOMEPAGE="http://mate-desktop.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"

IUSE="X dbus exif jpeg lcms python svg tiff xmp"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
	dev-libs/atk:0
	>=dev-libs/glib-2.25.9:2
	>=dev-libs/libxml2-2:2
	>=mate-base/mate-desktop-1.6:0
	sys-libs/zlib:0
	x11-libs/cairo:0
	>=x11-libs/gdk-pixbuf-2.4:2[jpeg?,tiff?]
	>=x11-libs/gtk+-2.18:2
	x11-libs/libX11:0
	>=x11-misc/shared-mime-info-0.20:0
	>=x11-themes/mate-icon-theme-1.6:0
	virtual/libintl:0
	dbus? ( >=dev-libs/dbus-glib-0.71:0 )
	exif? (
		>=media-libs/libexif-0.6.14:0
		virtual/jpeg:0 )
	jpeg? ( virtual/jpeg:0 )
	lcms? ( media-libs/lcms:0 )
	python? (
		${PYTHON_DEPS}
		>=dev-python/pygobject-2.15.1:2[${PYTHON_USEDEP}]
		>=dev-python/pygtk-2.13:2[${PYTHON_USEDEP}] )
	svg? ( >=gnome-base/librsvg-2.26:2 )
	xmp? ( >=media-libs/exempi-1.99.5:2 )"

DEPEND="${RDEPEND}
	>=app-text/mate-doc-utils-1.6:0
	>=dev-util/intltool-0.40:*
	sys-devel/gettext:*
	virtual/pkgconfig:*"

src_prepare() {
	# Fix ui translations, fixed upstream so next release should be ok.
	sed -e 's|(PACKAGE|(GETTEXT_PACKAGE|g' \
		-i src/main.c || die

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		$(use_enable python) \
		$(use_with jpeg libjpeg) \
		$(use_with exif libexif) \
		$(use_with dbus) \
		$(use_with lcms cms) \
		$(use_with xmp) \
		$(use_with svg librsvg) \
		$(use_with X x) \
		--without-cms
}

DOCS="AUTHORS ChangeLog HACKING NEWS README THANKS TODO"
