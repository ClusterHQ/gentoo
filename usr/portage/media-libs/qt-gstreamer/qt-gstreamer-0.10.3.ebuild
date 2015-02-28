# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/qt-gstreamer/qt-gstreamer-0.10.3.ebuild,v 1.6 2014/08/10 21:11:33 slyfox Exp $

EAPI=5

QT_MINIMAL="4.7.0"

if [[ ${PV} != *9999* ]]; then
	SRC_URI="http://gstreamer.freedesktop.org/src/${PN}/${P}.tar.bz2"
	KEYWORDS="amd64 ~arm x86"
else
	GIT_ECLASS="git-r3"
	EGIT_REPO_URI=( "git://anongit.freedesktop.org/gstreamer/${PN}" )
	KEYWORDS=""
fi

inherit cmake-utils ${GIT_ECLASS}

DESCRIPTION="QtGStreamer provides C++ bindings for GStreamer with a Qt-style API"
HOMEPAGE="http://gstreamer.freedesktop.org/wiki/QtGStreamer"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="test"

RDEPEND="
	dev-libs/glib:2
	>=dev-libs/boost-1.40:=
	>=dev-util/boost-build-1.40
	>=media-libs/gstreamer-0.10.33:0.10
	>=media-libs/gst-plugins-base-0.10.33:0.10
	>=dev-qt/qtcore-${QT_MINIMAL}:4
	>=dev-qt/qtdeclarative-${QT_MINIMAL}:4
	>=dev-qt/qtgui-${QT_MINIMAL}:4
	>=dev-qt/qtopengl-${QT_MINIMAL}:4
"
DEPEND="
	${RDEPEND}
	test? ( >=dev-qt/qttest-${QT_MINIMAL}:4 )
"

# bug 497880
RESTRICT="test"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use test QTGSTREAMER_TESTS)
	)

	cmake-utils_src_configure
}
