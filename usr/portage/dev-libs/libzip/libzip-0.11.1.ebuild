# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libzip/libzip-0.11.1.ebuild,v 1.6 2013/09/05 13:24:31 ago Exp $

EAPI=5

MY_P=${P/_}

AUTOTOOLS_AUTORECONF=1
inherit autotools-utils eutils

DESCRIPTION="Library for manipulating zip archives"
HOMEPAGE="http://www.nih.at/libzip/"
SRC_URI="http://www.nih.at/libzip/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm hppa ~ia64 ~mips ppc ppc64 ~sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="static-libs"

DEPEND="sys-libs/zlib"
RDEPEND="${DEPEND}"

DOCS=( NEWS README THANKS AUTHORS )

S=${WORKDIR}/${MY_P}

PATCHES=(
	"${FILESDIR}/${PN}-0.10_rc1-fix_headers.patch"
	"${FILESDIR}/${PN}-0.11-fix_pkgconfig.patch"
)

AUTOTOOLS_IN_SOURCE_BUILD=1

RESTRICT="test"

src_prepare() {
	autotools-utils_src_prepare
	# run due to fix_headers patch
	AT_NOELIBTOOLIZE=yes eautoreconf
	#elibtoolize # FreeBSD .so version

	# fix test return state
	sed -i \
		-e 's:19/2:19/0:' \
		regress/open_nonarchive.test || die
}

src_install() {
	autotools-utils_src_install
	prune_libtool_files --all
}

src_test() {
	#Having VERBOSE as an env variable causes the fread test to fail (bug 421651)
	unset VERBOSE
	autotools-utils_src_test
}
