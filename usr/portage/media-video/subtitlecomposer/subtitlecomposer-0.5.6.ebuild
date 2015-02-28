# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/subtitlecomposer/subtitlecomposer-0.5.6.ebuild,v 1.1 2014/03/16 12:22:38 johu Exp $

EAPI=5

KDE_LINGUAS="bg cs de el es fr hu pl pt_BR ru sr sr@latin uk"
KDE_LINGUAS_LIVE_OVERRIDE="true"
inherit kde4-base

DESCRIPTION="Text-based subtitles editor"
HOMEPAGE="https://github.com/maxrd2/subtitlecomposer"
SRC_URI="https://github.com/maxrd2/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="4"
IUSE="debug gstreamer unicode xine"

RDEPEND="
	media-libs/phonon
	gstreamer? ( media-libs/gstreamer:0.10 )
	unicode? ( dev-libs/icu:= )
	xine? ( media-libs/xine-lib )
"
DEPEND="${RDEPEND}
	sys-devel/gettext
"

src_configure() {
	mycmakeargs=(
		$(cmake-utils_use_with gstreamer GStreamer)
		$(cmake-utils_use_with unicode ICU)
		$(cmake-utils_use_with xine)
	)
	kde4-base_src_configure
}

pkg_postinst() {
	kde4-base_pkg_postinst

	echo
	elog "Some example scripts provided by ${PV} require dev-lang/ruby"
	elog "or dev-lang/python to be installed."
	echo
}
