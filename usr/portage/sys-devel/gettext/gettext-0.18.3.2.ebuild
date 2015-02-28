# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gettext/gettext-0.18.3.2.ebuild,v 1.3 2014/01/30 22:12:30 axs Exp $

EAPI="4"

inherit flag-o-matic eutils multilib toolchain-funcs mono-env libtool java-pkg-opt-2 multilib-minimal

DESCRIPTION="GNU locale utilities"
HOMEPAGE="http://www.gnu.org/software/gettext/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-3 LGPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="acl -cvs doc emacs git java nls +cxx ncurses openmp static-libs elibc_glibc"

# only runtime goes multilib
DEPEND="virtual/libiconv[${MULTILIB_USEDEP}]
	dev-libs/libxml2
	dev-libs/expat
	acl? ( virtual/acl )
	ncurses? ( sys-libs/ncurses )
	java? ( >=virtual/jdk-1.4 )"
RDEPEND="${DEPEND}
	!git? ( cvs? ( dev-vcs/cvs ) )
	git? ( dev-vcs/git )
	java? ( >=virtual/jre-1.4 )
	abi_x86_32? (
		!app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)]
		!<=app-emulation/emul-linux-x86-baselibs-20131008-r11
	)"
PDEPEND="emacs? ( app-emacs/po-mode )"

MULTILIB_WRAPPED_HEADERS=(
	# only installed for native ABI
	/usr/include/gettext-po.h
)

src_prepare() {
	java-pkg-opt-2_src_prepare
	# this script uses syntax that Solaris /bin/sh doesn't grok
	sed -i -e '1c\#!/usr/bin/env sh' \
		"${S}"/gettext-tools/misc/convert-archive.in || die

#	# work around problem in gnulib on OSX Lion, Mountain Lion and Mavericks
#	if [[ ${CHOST} == *-darwin1[123] ]] ; then
#		sed -i -e '/^#ifndef weak_alias$/a\# undef __stpncpy' \
#			gettext-tools/gnulib-lib/stpncpy.c || die
#		sed -i -e '/^# undef __stpncpy$/a\# undef stpncpy' \
#			gettext-tools/gnulib-lib/stpncpy.c || die
#	fi

	epunt_cxx
	elibtoolize
}

multilib_src_configure() {
	local myconf=(
		# switches common to runtime and top-level
		--cache-file="${BUILD_DIR}"/config.cache
		--docdir="${EPREFIX}/usr/share/doc/${PF}"

		$(use_enable cxx libasprintf)
		$(use_enable java)
		$(use_enable static-libs static)
	)

	# Build with --without-included-gettext (on glibc systems)
	if use elibc_glibc ; then
		myconf+=(
			--without-included-gettext
			$(use_enable nls)
		)
	else
		myconf+=(
			--with-included-gettext
			--enable-nls
		)
	fi
	use cxx || export CXX=$(tc-getCC)

	# Should be able to drop this hack in next release. #333887
	tc-is-cross-compiler && export gl_cv_func_working_acl_get_file=yes

	local ECONF_SOURCE=${S}
	if ! multilib_build_binaries ; then
		# for non-native ABIs, we build runtime only
		ECONF_SOURCE+=/gettext-runtime
	else
		# remaining switches
		myconf+=(
			# Emacs support is now in a separate package
			--without-emacs
			--without-lispdir
			# glib depends on us so avoid circular deps
			--with-included-glib
			# libcroco depends on glib which ... ^^^
			--with-included-libcroco
			# this will _disable_ libunistring (since it is not bundled),
			# see bug #326477
			--with-included-libunistring

			$(use_enable acl)
			$(use_enable ncurses curses)
			$(use_enable openmp)
			$(use_with git)
			$(usex git --without-cvs $(use_with cvs))
		)
	fi

	econf "${myconf[@]}"
}

multilib_src_install() {
	default

	if multilib_build_binaries ; then
		dosym msgfmt /usr/bin/gmsgfmt #43435
		dobin gettext-tools/misc/gettextize

		[[ ${USERLAND} == "BSD" ]] && gen_usr_ldscript -a intl
	fi
}

multilib_src_install_all() {
	use nls || rm -r "${ED}"/usr/share/locale
	use static-libs || prune_libtool_files --all

	rm -f "${ED}"/usr/share/locale/locale.alias "${ED}"/usr/lib/charset.alias

	if use java ; then
		java-pkg_dojar "${ED}"/usr/share/${PN}/*.jar
		rm -f "${ED}"/usr/share/${PN}/*.jar
		rm -f "${ED}"/usr/share/${PN}/*.class
		if use doc ; then
			java-pkg_dojavadoc "${ED}"/usr/share/doc/${PF}/javadoc2
			rm -rf "${ED}"/usr/share/doc/${PF}/javadoc2
		fi
	fi

	if use doc ; then
		dohtml "${ED}"/usr/share/doc/${PF}/*.html
	else
		rm -rf "${ED}"/usr/share/doc/${PF}/{csharpdoc,examples,javadoc2,javadoc1}
	fi
	rm -f "${ED}"/usr/share/doc/${PF}/*.html

	dodoc AUTHORS ChangeLog NEWS README THANKS
}

pkg_preinst() {
	# older gettext's sometimes installed libintl ...
	# need to keep the linked version or the system
	# could die (things like sed link against it :/)
	preserve_old_lib /{,usr/}$(get_libdir)/libintl$(get_libname 7)

	java-pkg-opt-2_pkg_preinst
}

pkg_postinst() {
	preserve_old_lib_notify /{,usr/}$(get_libdir)/libintl$(get_libname 7)
}
