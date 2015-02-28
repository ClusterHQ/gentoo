# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-qt/qtdeclarative/qtdeclarative-5.3.1-r3.ebuild,v 1.1 2014/09/11 01:44:35 pesa Exp $

EAPI=5

inherit qt5-build

DESCRIPTION="The QML and Quick modules for the Qt5 framework"

if [[ ${QT5_BUILD_TYPE} == live ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~x86"
fi

IUSE="gles2 localstorage +widgets xml"

# qtgui[gles2=] is needed because of bug 504322
DEPEND="
	>=dev-qt/qtcore-${PV}:5[debug=]
	>=dev-qt/qtgui-${PV}:5[debug=,gles2=,opengl]
	>=dev-qt/qtnetwork-${PV}:5[debug=]
	>=dev-qt/qttest-${PV}:5[debug=]
	localstorage? ( >=dev-qt/qtsql-${PV}:5[debug=] )
	widgets? ( >=dev-qt/qtwidgets-${PV}:5[debug=] )
	xml? ( >=dev-qt/qtxmlpatterns-${PV}:5[debug=] )
"
RDEPEND="${DEPEND}"

src_prepare() {
	use localstorage || sed -i -e '/localstorage/d' \
		src/imports/imports.pro || die

	use widgets || sed -i -e 's/contains(QT_CONFIG, no-widgets)/true/' \
		src/qmltest/qmltest.pro || die

	qt_use_disable_mod widgets widgets \
		src/src.pro \
		tools/tools.pro \
		tools/qmlscene/qmlscene.pro \
		tools/qml/qml.pro

	qt_use_disable_mod xml xmlpatterns \
		src/imports/imports.pro \
		tests/auto/quick/quick.pro

	qt5-build_src_prepare
}
