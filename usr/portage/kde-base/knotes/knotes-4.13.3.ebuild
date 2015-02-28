# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/knotes/knotes-4.13.3.ebuild,v 1.1 2014/07/16 17:40:24 johu Exp $

EAPI=5

KDE_HANDBOOK="optional"
KMNAME="kdepim"
inherit kde4-meta

DESCRIPTION="KDE Notes application"
HOMEPAGE="http://www.kde.org/applications/utilities/knotes/"
KEYWORDS="~amd64 ~arm ~x86 ~amd64-linux ~x86-linux"
IUSE="debug"

DEPEND="
	$(add_kdebase_dep kdepimlibs)
	$(add_kdebase_dep kdepim-common-libs)
"
RDEPEND="${DEPEND}"

KMCOMPILEONLY="
	noteshared/
"

KMEXTRACTONLY="
	akonadi_next/
	pimcommon/
"

KMLOADLIBS="kdepim-common-libs"
