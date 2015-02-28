# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/dolphin/dolphin-4.12.5.ebuild,v 1.6 2014/05/12 01:51:33 reavertm Exp $

EAPI=5

KDE_HANDBOOK="optional"
KMNAME="kde-baseapps"
inherit kde4-meta

DESCRIPTION="A KDE filemanager focusing on usability"
HOMEPAGE="http://dolphin.kde.org http://www.kde.org/applications/system/dolphin"
KEYWORDS=" amd64 ~arm ppc ppc64 x86 ~amd64-linux ~x86-linux"
IUSE="debug semantic-desktop thumbnail"

DEPEND="
	$(add_kdebase_dep kactivities)
	$(add_kdebase_dep kdelibs 'semantic-desktop?')
	$(add_kdebase_dep libkonq)
	x11-libs/libXrender
	semantic-desktop? (
		>=dev-libs/shared-desktop-ontologies-0.11.0
		dev-libs/soprano
		$(add_kdebase_dep nepomuk-core)
		$(add_kdebase_dep nepomuk-widgets)
	)
"
RDEPEND="${DEPEND}
	$(add_kdebase_dep kfind)
	thumbnail? (
		$(add_kdebase_dep thumbnailers)
		|| (
			$(add_kdebase_dep ffmpegthumbs)
			$(add_kdebase_dep mplayerthumbs)
		)
	)
"

RESTRICT="test"
# bug 393129

src_configure() {
	mycmakeargs=(
		$(cmake-utils_use_with semantic-desktop NepomukCore)
		$(cmake-utils_use_with semantic-desktop NepomukWidgets)
		$(cmake-utils_use_with semantic-desktop Soprano)
	)

	kde4-meta_src_configure
}

pkg_postinst() {
	kde4-base_pkg_postinst

	if ! has_version media-gfx/icoutils ; then
		elog "For .exe file preview support, install media-gfx/icoutils."
	fi
}
