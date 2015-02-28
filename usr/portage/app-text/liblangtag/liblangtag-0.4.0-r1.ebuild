# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/liblangtag/liblangtag-0.4.0-r1.ebuild,v 1.7 2013/04/26 19:13:02 scarabeus Exp $

EAPI=5

AUTOTOOLS_AUTORECONF=true

inherit autotools-utils

DESCRIPTION="An interface library to access tags for identifying languages"
HOMEPAGE="http://tagoh.bitbucket.org/liblangtag/"
SRC_URI="https://bitbucket.org/tagoh/${PN}/downloads/${P}.tar.bz2"

LICENSE="|| ( LGPL-3 MPL-1.1 )"
SLOT="0"
KEYWORDS="amd64 ~arm ppc x86"
IUSE="introspection static-libs test"

RDEPEND="
	dev-libs/glib
	dev-libs/libxml2
	introspection? ( >=dev-libs/gobject-introspection-0.10.8 )"
DEPEND="${RDEPEND}
	dev-libs/gobject-introspection-common
	sys-devel/gettext
	test? ( dev-libs/check )"

# Upstream expect liblangtag to be installed when one runs tests...
RESTRICT="test"

PATCHES=(
	"${FILESDIR}"/${P}-module.patch
	"${FILESDIR}"/${P}-arm.patch
	"${FILESDIR}"/${P}-introspection.patch
)

src_prepare() {
	sed -i \
		-e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:g' \
		configure.ac || die

	autotools-utils_src_prepare
}

src_configure() {
	local myeconfargs=(
		$(use_enable introspection)
		$(use_enable test)
	)
	autotools-utils_src_configure
}
