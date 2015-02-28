# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.24.51.0.2.ebuild,v 1.2 2014/01/06 18:29:21 vapier Exp $

PATCHVER="1.1"
ELF2FLT_VER=""
inherit toolchain-binutils

#KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

src_unpack() {
	toolchain-binutils_src_unpack
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2.22-mint.patch
	epatch "${FILESDIR}"/${PN}-2.19.50.0.1-mint.patch
}

src_compile() {
	if has noinfo "${FEATURES}" \
	|| ! type -p makeinfo >/dev/null
	then
		# binutils >= 2.17 (accidentally?) requires 'makeinfo'
		export EXTRA_EMAKE="MAKEINFO='echo makeinfo GNU texinfo 4.13'"
	fi

	case "${CTARGET}" in
	*-interix*) EXTRA_ECONF="${EXTRA_ECONF} --without-gnu-ld --without-gnu-as" ;;
	esac

	toolchain-binutils_src_compile
}

src_install() {
	toolchain-binutils_src_install

	case "${CTARGET}" in
    *-interix*)
		ln -s /opt/gcc.3.3/bin/as "${ED}${BINPATH}"/as || die "Cannot create as symlink"
		sed -e "s,@SCRIPTDIR@,${EPREFIX}${LIBPATH}/ldscripts," \
			< "${FILESDIR}"/2.21-ldwrap-interix.sh \
			> "${ED}${BINPATH}"/ld \
			|| die "Cannot create ld wrapper"
		chmod a+x "${ED}${BINPATH}"/ld

		dodir "${LIBPATH}"/ldscripts

		# yes, this is "i586-pc-interix3" for SFU 3.5, SUA 5.2 and SUA 6.0
		# additionally insert the prefix as absolute top search dir...
		for x in /opt/gcc.3.3/i586-pc-interix3/lib/ldscripts/i386pe_posix.*; do
			sed -e 's, SEARCH_DIR("/usr/local/lib"); , SEARCH_DIR("/usr/lib/x86"); ,' \
				-e "s,^\(SEARCH_DIR(\),SEARCH_DIR(\"${EPREFIX}/lib\"); SEARCH_DIR(\"${EPREFIX}/usr/lib\"); \1," \
			< $x \
			> "${ED}${LIBPATH}"/ldscripts/${x##*/} \
			|| die "Cannot occupy ldscripts"
		done
		;;
	esac
}
