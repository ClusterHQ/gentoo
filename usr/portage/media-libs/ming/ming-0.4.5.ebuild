# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/ming/ming-0.4.5.ebuild,v 1.2 2014/08/29 20:31:03 axs Exp $

EAPI=5

PYTHON_COMPAT=( python2_7 )
PHP_EXT_NAME=ming
PHP_EXT_OPTIONAL_USE=php
AUTOTOOLS_AUTORECONF=yes
GENTOO_DEPEND_ON_PERL=no
inherit autotools-utils flag-o-matic multilib php-ext-source-r2 perl-module distutils-r1

DESCRIPTION="An Open Source library for Flash movie generation"
HOMEPAGE="http://ming.sourceforge.net/"
SRC_URI="mirror://sourceforge/ming/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd"
IUSE="+perl +python php static-libs"

RDEPEND="perl? ( dev-lang/perl:= )
	python? ( ${PYTHON_DEPS} )
	media-libs/freetype
	media-libs/libpng:=
	media-libs/giflib
	sys-libs/zlib
	!media-libs/libswf"
DEPEND="${RDEPEND}
	sys-devel/flex
	virtual/yacc"

S=${WORKDIR}/${P/_/.}
PATCHES=( "${FILESDIR}"/${P}-gif-error.patch )

# Tests only work when the package is tested on a system
# which does not presently have any version of ming installed.
RESTRICT="test"

src_prepare() {
	# Let's get rid of the TEXTRELS, link dynamic. Use gif.
	sed -i \
		-e 's/libming.a/libming.so/' \
		-e 's/lungif/lgif/' \
		perl_ext/Makefile.PL
	sed -i \
		-e 's/ungif/gif/' \
		py_ext/setup.py.in

	if use php; then
		cd "${S}/php_ext"
		php-ext-source-r2_phpize
		cd "${S}"
	fi

	sed -i -e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:' configure.in || die

	autotools-utils_src_prepare
}

src_configure() {
	# build is sensitive to -O3 (bug #297437)
	replace-flags -O3 -O2

	# build python via distutils calls, disable here
	local myeconfargs=(
		--disable-python
		$(use_enable static-libs static)
		$(use_enable perl)
		)
	autotools-utils_src_configure
}

run_distutils() {
	if use python; then
		pushd "${BUILD_DIR}"/py_ext > /dev/null || die
		distutils-r1_"${@}"
		popd > /dev/null || die
	fi
}

src_compile() {
	autotools-utils_src_compile

	run_distutils ${FUNCNAME}

	if use php; then
		cd "${S}"/php_ext
		myconf="--disable-rpath
			--disable-static
			--with-ming"
		php-ext-source-r2_src_compile
	fi
}

src_install() {
	run_distutils ${FUNCNAME}

	autotools-utils_src_install INSTALLDIRS="vendor"

	fixlocalpod

	if use php; then
		cd "${S}"/php_ext
		php-ext-source-r2_src_install
	fi
}

pkg_postinst() {
	use perl && perl-module_pkg_postinst
}

pkg_prerm() {
	use perl && perl-module_pkg_prerm
}

pkg_postrm() {
	use perl && perl-module_pkg_postrm
}
