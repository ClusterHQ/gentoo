# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/phonon-vlc/phonon-vlc-0.6.2.ebuild,v 1.5 2013/04/09 16:42:26 ago Exp $

EAPI=5

MY_PN="phonon-backend-vlc"
MY_P="${MY_PN}-${PV}"
EGIT_REPO_URI="git://anongit.kde.org/${PN}"
[[ ${PV} == 9999 ]] && git_eclass=git-2
inherit cmake-utils ${git_eclass}
unset git_eclass

DESCRIPTION="Phonon VLC backend"
HOMEPAGE="https://projects.kde.org/projects/kdesupport/phonon/phonon-vlc"
[[ ${PV} == 9999 ]] || SRC_URI="mirror://kde/stable/phonon/${MY_PN}/${PV}/${MY_P}.tar.xz"

LICENSE="LGPL-2.1"

# Don't move KEYWORDS on the previous line or ekeyword won't work # 399061
[[ ${PV} == 9999 ]] || \
KEYWORDS="amd64 ~arm ppc ppc64 x86 ~amd64-fbsd"

SLOT="0"
IUSE="debug"

RDEPEND="
	>=media-libs/phonon-4.6.0
	>=media-video/vlc-2.0.1[dbus,ogg,vorbis]
	>=dev-qt/qtcore-4.6.0:4
	>=dev-qt/qtdbus-4.6.0:4
	>=dev-qt/qtgui-4.6.0:4
"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	>=dev-util/automoc-0.9.87
	virtual/pkgconfig
"

S=${WORKDIR}/${MY_P}

DOCS=( AUTHORS )

src_configure() {
	local mycmakeargs=(
		-DPhonon_DIR=/usr/$(get_libdir)/cmake/phonon/
	)
	cmake-utils_src_configure
}

pkg_postinst() {
	elog "For more verbose debug information, export the following variables:"
	elog "PHONON_DEBUG=1"
	elog ""
	elog "To make KDE detect the new backend without reboot, run:"
	elog "kbuildsycoca4 --noincremental"
}
