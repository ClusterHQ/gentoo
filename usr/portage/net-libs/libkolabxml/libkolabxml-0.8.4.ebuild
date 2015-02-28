# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libkolabxml/libkolabxml-0.8.4.ebuild,v 1.5 2013/06/08 10:14:29 ago Exp $

EAPI=5

inherit cmake-utils multilib

DESCRIPTION="Kolab XML format schema definitions library"
HOMEPAGE="http://www.kolab.org"
SRC_URI="http://mirror.kolabsys.com/pub/releases/${P}.tar.gz"

LICENSE="Apache-2.0 ZLIB LGPL-3+ public-domain"
SLOT="4"
KEYWORDS="amd64 ~arm ppc ppc64 x86"
IUSE="csharp java python php test"

RDEPEND="
	dev-cpp/xsd
	>=dev-libs/boost-1.42.0:=
	dev-libs/xerces-c
	net-misc/curl
"
DEPEND="
	${RDEPEND}
	csharp? ( >=dev-lang/swig-2.0.7 dev-lang/mono )
	java? ( >=dev-lang/swig-2.0.7 virtual/jre )
	php? ( >=dev-lang/swig-2.0.7 dev-lang/php )
	python? ( >=dev-lang/swig-2.0.7 dev-lang/python )
	test? ( dev-qt/qttest:4 )
"

src_configure() {
	local mycmakeargs=(
		-DLIB_INSTALL_DIR=$(get_libdir)
		$(cmake-utils_use csharp CSHARP_BINDINGS)
		$(cmake-utils_use java JAVA_BINDINGS)
		$(cmake-utils_use python PYTHON_BINDINGS)
		$(cmake-utils_use php PHP_BINDINGS)
		$(cmake-utils_use_build test TESTS)
	)
	cmake-utils_src_configure
}
