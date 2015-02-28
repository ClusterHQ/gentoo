# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/audiocd-kio/audiocd-kio-4.14.0.ebuild,v 1.1 2014/08/20 16:02:48 johu Exp $

EAPI=5

KDE_HANDBOOK="optional"
inherit kde4-base

DESCRIPTION="KDE kioslaves from the kdemultimedia package"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux"
IUSE="debug flac vorbis"

DEPEND="
	$(add_kdebase_dep libkcddb)
	$(add_kdebase_dep libkcompactdisc)
	media-sound/cdparanoia
	flac? ( >=media-libs/flac-1.1.2 )
	vorbis? (
		media-libs/libogg
		media-libs/libvorbis
	)
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_with flac)
		$(cmake-utils_use_with vorbis OggVorbis)
	)

	kde4-base_src_configure
}
