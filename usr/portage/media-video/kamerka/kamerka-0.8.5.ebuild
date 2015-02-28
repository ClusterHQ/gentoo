# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/kamerka/kamerka-0.8.5.ebuild,v 1.4 2013/06/11 15:53:10 ago Exp $

EAPI=5
KDE_LINGUAS="cs de es nl pl pt sr sr@ijekavian sr@ijekavianlatin sr@latin zh_TW"
inherit kde4-base

SRC_URI="http://dosowisko.net/${PN}/downloads/${P}.tar.gz"
DESCRIPTION="Simple photo taking application with fancy animated interface"
HOMEPAGE="http://dos1.github.com/kamerka/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	media-libs/libv4l
	media-libs/phonon
	>=dev-qt/qtdeclarative-4.7:4
"
DEPEND="${RDEPEND}"
