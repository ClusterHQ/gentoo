# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-qt/assistant/assistant-5.3.1-r3.ebuild,v 1.1 2014/09/11 01:42:46 pesa Exp $

EAPI=5

QT5_MODULE="qttools"

inherit qt5-build

DESCRIPTION="Tool for viewing on-line documentation in Qt help file format"

if [[ ${QT5_BUILD_TYPE} == live ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~x86"
fi

IUSE="webkit"

DEPEND="
	>=dev-qt/qtcore-${PV}:5[debug=]
	>=dev-qt/qtgui-${PV}:5[debug=]
	>=dev-qt/qthelp-${PV}:5[debug=]
	>=dev-qt/qtnetwork-${PV}:5[debug=]
	>=dev-qt/qtprintsupport-${PV}:5[debug=]
	>=dev-qt/qtsql-${PV}:5[debug=,sqlite]
	>=dev-qt/qtwidgets-${PV}:5[debug=]
	webkit? ( >=dev-qt/qtwebkit-${PV}:5[debug=,widgets] )
"
RDEPEND="${DEPEND}"

QT5_TARGET_SUBDIRS=(
	src/assistant/assistant
)

src_prepare() {
	qt_use_disable_mod webkit webkitwidgets \
		src/assistant/assistant/assistant.pro

	qt5-build_src_prepare
}
