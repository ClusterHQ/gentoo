# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-qt/qtgraphicaleffects/qtgraphicaleffects-5.3.1-r3.ebuild,v 1.1 2014/09/11 01:44:47 pesa Exp $

EAPI=5

inherit qt5-build virtualx

DESCRIPTION="Set of QML types for adding visual effects to user interfaces"

if [[ ${QT5_BUILD_TYPE} == live ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~x86"
fi

IUSE=""

RDEPEND="
	>=dev-qt/qtcore-${PV}:5[debug=]
	>=dev-qt/qtdeclarative-${PV}:5[debug=]
	>=dev-qt/qtxmlpatterns-${PV}:5[debug=]
"
DEPEND="${RDEPEND}
	test? ( >=dev-qt/qtgui-${PV}:5[debug=] )
"

src_test() {
	local VIRTUALX_COMMAND="qt5-build_src_test"
	virtualmake
}
