# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/ksmserver/ksmserver-4.11.9.ebuild,v 1.5 2014/05/08 07:32:19 ago Exp $

EAPI=5

DECLARATIVE_REQUIRED="always"
KMNAME="kde-workspace"
inherit kde4-meta

DESCRIPTION="The reliable KDE session manager that talks the standard X11R6"
KEYWORDS="amd64 ~arm ppc ppc64 x86 ~amd64-linux ~x86-linux"
IUSE="debug"

DEPEND="
	$(add_kdebase_dep kcminit)
	$(add_kdebase_dep libkworkspace)
	media-libs/qimageblitz
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXrender
"
RDEPEND="${DEPEND}
	$(add_kdebase_dep kdm)
"

KMEXTRACTONLY="
	kcminit/main.h
	libs/kdm/kgreeterplugin.h
	kcheckpass/
	libs/kephal/
	libs/kworkspace/
"

KMLOADLIBS="libkworkspace"
