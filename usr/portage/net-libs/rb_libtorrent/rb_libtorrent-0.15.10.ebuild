# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/rb_libtorrent/rb_libtorrent-0.15.10.ebuild,v 1.7 2012/11/08 06:24:13 flameeyes Exp $

EAPI="4"
PYTHON_DEPEND="python? 2:2.6"
PYTHON_USE_WITH="threads"
PYTHON_USE_WITH_OPT="python"

inherit multilib python versionator

MY_P=${P/rb_/}
MY_P=${MY_P/torrent/torrent-rasterbar}
S=${WORKDIR}/${MY_P}

DESCRIPTION="C++ BitTorrent implementation focusing on efficiency and scalability"
HOMEPAGE="http://www.rasterbar.com/products/libtorrent/"
SRC_URI="http://libtorrent.googlecode.com/files/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~arm ppc ~ppc64 ~sparc x86 ~x86-fbsd"
IUSE="debug doc examples python ssl static-libs"
RESTRICT="test"

DEPEND=">=dev-libs/boost-1.48[python?,threads(+)]
	>=sys-devel/libtool-2.2
	sys-libs/zlib
	examples? ( !net-p2p/mldonkey )
	ssl? ( dev-libs/openssl )"

RDEPEND="${DEPEND}"

pkg_setup() {
	if use python; then
		python_set_active_version 2
		python_pkg_setup
	fi
}

src_prepare() {
	use python && python_convert_shebangs -r 2 .
}

src_configure() {
	# use multi-threading versions of boost libs
	local BOOST_LIBS="--with-boost-system=boost_system-mt \
		--with-boost-filesystem=boost_filesystem-mt \
		--with-boost-thread=boost_thread-mt \
		--with-boost-python=boost_python-${PYTHON_ABI}-mt"

	local LOGGING
	use debug && LOGGING="--enable-logging=verbose"

	econf $(use_enable debug) \
		$(use_enable test tests) \
		$(use_enable examples) \
		$(use_enable python python-binding) \
		$(use_enable ssl encryption) \
		$(use_enable static-libs static) \
		--with-zlib=system \
		${LOGGING} \
		${BOOST_LIBS}
}

src_install() {
	emake DESTDIR="${D}" install
	use static-libs || find "${D}" -name '*.la' -exec rm -f {} +
	dodoc ChangeLog AUTHORS NEWS README
	if use doc; then
		dohtml docs/*
	fi
}
