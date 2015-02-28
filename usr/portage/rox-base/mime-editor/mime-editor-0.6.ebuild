# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/rox-base/mime-editor/mime-editor-0.6.ebuild,v 1.6 2013/08/03 07:31:09 ago Exp $

ROX_LIB_VER="2.0.4-r1"
inherit rox-0install

DESCRIPTION="MIME-Editor is editor for the Shared MIME Database for ROX Desktop"
HOMEPAGE="http://rox.sourceforge.net/"
SRC_URI="mirror://sourceforge/rox/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ppc sparc x86"
IUSE=""

APPNAME=MIME-Editor
APPCATEGORY="System;Core"
