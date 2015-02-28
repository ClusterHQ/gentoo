# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/qmmp-plugin-pack/qmmp-plugin-pack-0.7.4.ebuild,v 1.1 2014/01/02 19:01:29 hwoarang Exp $

EAPI=5

CMAKE_MIN_VERSION=2.8

inherit cmake-utils

DESCRIPTION="A set of extra plugins for Qmmp"
HOMEPAGE="http://code.google.com/p/qmmp"
SRC_URI="http://qmmp.googlecode.com/files/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=media-libs/taglib-1.7.0
	>=media-sound/mpg123-1.13.0
	>=media-sound/qmmp-0.7.0
	dev-qt/qtgui:4"
DEPEND="${RDEPEND}
	dev-lang/yasm"
