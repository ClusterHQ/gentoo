# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/kdepim-common-libs/kdepim-common-libs-4.13.3.ebuild,v 1.1 2014/07/16 17:40:48 johu Exp $

EAPI=5

KMNAME="kdepim"
KMNOMODULE="true"
inherit kde4-meta

DESCRIPTION="Common libraries for KDE PIM apps"
KEYWORDS="~amd64 ~arm ~x86 ~amd64-linux ~x86-linux"
IUSE="debug"

DEPEND="
	app-crypt/gpgme
	>=app-office/akonadi-server-1.12.1
	dev-libs/grantlee
	$(add_kdebase_dep baloo)
	$(add_kdebase_dep kdepimlibs)
"
RDEPEND="${DEPEND}
	!kde-base/akonadi:4
	!kde-base/libkdepim:4
	!kde-base/libkleo:4
	!kde-base/libkpgp:4
	!<kde-base/kaddressbook-4.11.50:4
	!kde-base/kdepim-wizards:4
	!<kde-base/kmail-4.4.80:4
	!=kde-base/kmail-4.12.0
	!=kde-base/kmail-4.12.1
	!=kde-base/kmail-4.11*
	!<kde-base/korganizer-4.5.67:4
	app-crypt/gnupg
	$(add_kdebase_dep kdepim-runtime)
"

RESTRICT="test"
# bug 393131

KMEXTRA="
	agents/sendlateragent/
	akonadi_next/
	calendarsupport/
	calendarviews/
	composereditor-ng/
	grantleetheme/
	kaddressbookgrantlee/
	incidenceeditor-ng/
	libkdepim/
	libkdepimdbusinterfaces/
	libkleo/
	libkpgp/
	kdgantt2/
	messagecomposer/
	messagecore/
	messagelist/
	messageviewer/
	noteshared/
	pimcommon/
	templateparser/
"
KMEXTRACTONLY="
	kleopatra/
	kmail/
	knode/org.kde.knode.xml
	korgac/org.kde.korganizer.KOrgac.xml
	korganizer/org.kde.korganizer.Korganizer.xml
	mailcommon/
"
KMSAVELIBS="true"

PATCHES=( "${FILESDIR}/install-composereditorng.patch" )

src_prepare() {
	kde4-meta_src_prepare
	sed -e '/folderarchiveagent.desktop/d' \
		-i agents/CMakeLists.txt || die
}
