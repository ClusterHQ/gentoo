# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/icu/icu-51.2-r2.ebuild,v 1.1 2013/12/26 11:12:24 mgorny Exp $

EAPI=5

inherit eutils toolchain-funcs autotools multilib-minimal

DESCRIPTION="International Components for Unicode"
HOMEPAGE="http://www.icu-project.org/"
SRC_URI="http://download.icu-project.org/files/icu4c/${PV/_/}/icu4c-${PV//./_}-src.tgz"

LICENSE="BSD"

SLOT="0/51.2"
# As far as I can remember, icu consumers reacted rather sensitive to icu upgrades in the past. 
# Even if revdep-rebuild did not rebuild (i.e. soname did not change), random crashes and 
# other irregularities occured until the consumers were rebuilt. So let's rather err on the side
# of caution and more rebuilds here. See also bug 464876. dilfridge

KEYWORDS="~ppc-aix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="debug doc examples static-libs"

DEPEND="
	doc? (
		app-doc/doxygen[dot]
	)
"

S="${WORKDIR}/${PN}/source"

PATCHES=(
	"${FILESDIR}/${PN}-51.1-CVE-2013-2924.patch"
)

src_prepare() {
	local variable

	epatch_user

	# Do not hardcode flags in icu-config and icu-*.pc files.
	# https://ssl.icu-project.org/trac/ticket/6102
	for variable in CFLAGS CPPFLAGS CXXFLAGS FFLAGS LDFLAGS; do
		sed \
			-e "/^${variable} =.*/s: *@${variable}@\( *$\)\?::" \
			-i config/icu.pc.in \
			-i config/Makefile.inc.in \
			|| die
	done

	# fix compilation on Solaris due to enabling of conflicting standards
	sed -i -e '/define _XOPEN_SOURCE_EXTENDED/s/_XOPEN/no_XOPEN/' \
		common/uposixdefs.h || die
	# for correct install_names
	epatch "${FILESDIR}"/${PN}-4.8.1-darwin.patch
	# fix part 1 for echo_{t,c,n}
	epatch "${FILESDIR}"/${PN}-4.6-echo_t.patch

	# Disable renaming as it is stupind thing to do
	sed -i \
		-e "s/#define U_DISABLE_RENAMING 0/#define U_DISABLE_RENAMING 1/" \
		common/unicode/uconfig.h || die

	# Fix linking of icudata
	sed -i \
		-e "s:LDFLAGSICUDT=-nodefaultlibs -nostdlib:LDFLAGSICUDT=:" \
		config/mh-linux || die

	# Append doxygen configuration to configure
	sed -i \
		-e 's:icudefs.mk:icudefs.mk Doxyfile:' \
		configure.in || die
	eautoreconf
}

src_configure() {
	if tc-is-cross-compiler; then
		mkdir "${WORKDIR}"/host || die
		pushd "${WORKDIR}"/host >/dev/null || die

		CFLAGS="" CXXFLAGS="" ASFLAGS="" LDFLAGS="" \
		CC="$(tc-getBUILD_CC)" CXX="$(tc-getBUILD_CXX)" AR="$(tc-getBUILD_AR)" \
		RANLIB="$(tc-getBUILD_RANLIB)" LD="$(tc-getBUILD_LD)" \
		"${S}"/configure --disable-renaming --disable-debug \
			--disable-samples --enable-static || die
		emake

		popd >/dev/null || die
	fi

	multilib-minimal_src_configure
}

multilib_src_configure() {
	local myeconfargs=(
		--disable-renaming
		--disable-samples
		$(use_enable debug)
		$(use_enable static-libs static)
	)

	multilib_build_binaries && myeconfargs+=(
		$(use_enable examples samples)
	)
	tc-is-cross-compiler && myeconfargs+=(
		--with-cross-build="${WORKDIR}"/host
	)

	# icu tries to use clang by default
	tc-export CC CXX

	# make sure we configure with the same shell as we run icu-config
	# with, or ECHO_N, ECHO_T and ECHO_C will be wrongly defined
	# (this is part 2 from the echo_{t,c,n} fix)
	export CONFIG_SHELL=${CONFIG_SHELL:-${EPREFIX}/bin/sh}

	ECONF_SOURCE=${S} \
	econf "${myeconfargs[@]}"
}

multilib_src_compile() {
	default

	if multilib_build_binaries && use doc; then
		doxygen -u Doxyfile || die
		doxygen Doxyfile || die
	fi
}

multilib_src_test() {
	# INTLTEST_OPTS: intltest options
	#   -e: Exhaustive testing
	#   -l: Reporting of memory leaks
	#   -v: Increased verbosity
	# IOTEST_OPTS: iotest options
	#   -e: Exhaustive testing
	#   -v: Increased verbosity
	# CINTLTST_OPTS: cintltst options
	#   -e: Exhaustive testing
	#   -v: Increased verbosity
	emake -j1 VERBOSE="1" check
}

multilib_src_install() {
	default

	if multilib_build_binaries && use doc; then
		dohtml -p api -r doc/html/
	fi
}

multilib_src_install_all() {
	einstalldocs
	dohtml ../readme.html
}
