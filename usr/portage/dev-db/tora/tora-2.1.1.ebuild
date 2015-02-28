# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/tora/tora-2.1.1.ebuild,v 1.13 2013/03/02 19:51:01 hwoarang Exp $

EAPI=2

inherit cmake-utils eutils

DESCRIPTION="TOra - Toolkit For Oracle"
HOMEPAGE="http://tora.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
IUSE="debug mysql oracle oci8-instant-client postgres"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64 ppc x86"

RDEPEND="${DEPEND}"
DEPEND="
	x11-libs/qscintilla
	dev-qt/qtgui:4
	dev-qt/qtsql:4[mysql?,postgres?]
	dev-qt/qtxmlpatterns:4
	oci8-instant-client? (
		dev-db/oracle-instantclient-basic
		dev-db/oracle-instantclient-sqlplus
	)
	postgres? ( dev-db/postgresql-server )
"

pkg_setup() {
	if ( use oracle || use oci8-instant-client ) && [ -z "$ORACLE_HOME" ] ; then
		eerror "ORACLE_HOME variable is not set."
		eerror
		eerror "You must install Oracle >= 8i client for Linux in"
		eerror "order to compile TOra with Oracle support."
		eerror
		eerror "Otherwise specify -oracle in your USE variable."
		eerror
		eerror "You can download the Oracle software from"
		eerror "http://otn.oracle.com/software/content.html"
		die
	fi
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-2.1.2-qt47.patch"

	sed -i \
		-e "/COPYING/ d" \
		CMakeLists.txt || die "Removal of COPYING file failed"
}

src_configure() {
	local mycmakeargs=()
	if use oracle || use oci8-instant-client ; then
		mycmakeargs=(-DENABLE_ORACLE=ON)
	else
		mycmakeargs=(-DENABLE_ORACLE=OFF)
	fi
	mycmakeargs+=(
		-DWANT_RPM=OFF
		-DWANT_BUNDLE=OFF
		-DWANT_BUNDLE_STANDALONE=OFF
		-DWANT_INTERNAL_QSCINTILLA=OFF
		$(cmake-utils_use_enable postgres PGSQL)
		$(cmake-utils_use_want debug)
		# path variables
		-DTORA_DOC_DIR=share/doc/${PF}
	)
	cmake-utils_src_configure
}
