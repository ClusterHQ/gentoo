# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/phonon-kde/phonon-kde-4.12.5.ebuild,v 1.5 2014/05/08 07:33:03 ago Exp $

EAPI=5

KMNAME="kde-runtime"
KMMODULE="phonon"
inherit kde4-meta

DESCRIPTION="Phonon KDE Integration"
HOMEPAGE="http://phonon.kde.org"
KEYWORDS="amd64 ~arm ppc ppc64 x86 ~amd64-linux ~x86-linux"
IUSE="alsa debug pulseaudio"

DEPEND="
	>=media-libs/phonon-4.4.3
	alsa? ( media-libs/alsa-lib )
	pulseaudio? (
		dev-libs/glib:2
		media-libs/libcanberra
		>=media-sound/pulseaudio-0.9.21[glib]
	)
"
RDEPEND="${DEPEND}"

src_configure() {
	mycmakeargs=(
		-DBUILD_tests=OFF
		-DWITH_Xine=OFF
		$(cmake-utils_use_with alsa)
		$(cmake-utils_use_with pulseaudio PulseAudio)
	)

	kde4-meta_src_configure
}
