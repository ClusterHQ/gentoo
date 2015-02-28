# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/libtool/libtool-2.4.2.ebuild,v 1.18 2014/01/18 03:56:58 vapier Exp $

EAPI="2" #356089

LIBTOOLIZE="true" #225559
WANT_LIBTOOL="none"
inherit eutils autotools multilib unpacker prefix

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="git://git.savannah.gnu.org/${PN}.git
		http://git.savannah.gnu.org/r/${PN}.git"
	inherit git-2
else
	SRC_URI="mirror://gnu/${PN}/${P}.tar.xz"
	KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
fi

DESCRIPTION="A shared library tool for developers"
HOMEPAGE="http://www.gnu.org/software/libtool/"

LICENSE="GPL-2"
SLOT="2"
IUSE="static-libs test vanilla"

RDEPEND="sys-devel/gnuconfig
	!<sys-devel/autoconf-2.62:2.5
	!<sys-devel/automake-1.11.1:1.11
	!=sys-devel/libtool-2*:1.5"
DEPEND="${RDEPEND}
	test? ( || ( >=sys-devel/binutils-2.20
		sys-devel/binutils-apple sys-devel/native-cctools ) )
	app-arch/xz-utils"
[[ ${PV} == "9999" ]] && DEPEND+=" sys-apps/help2man"

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		git-2_src_unpack
		cd "${S}"
		./bootstrap || die
	else
		unpacker_src_unpack
	fi

	# The libtool script used to create libltdl.la, and when installed used
	# by some crappy packages like dev-libs/apr, must be elibtoolize'd (for
	# AIX at least). However, the installed libtoolize script better is as
	# vanilla as possible, as it also may be used to create distribution
	# tarballs by independent package maintainers.
	mkdir "${WORKDIR}"/host-libtool || die
	cat >"${WORKDIR}"/host-libtool/configure.ac<<-EOF
		AC_INIT(host-libtool, ${PVR})
		$(grep '\<LT_INIT\>' "${S}"/configure.ac)
		$(grep '\<LT_LANG\>' "${S}"/configure.ac)
		AC_OUTPUT
	EOF
}

src_prepare() {
	use vanilla && return 0

	[[ ${CHOST} == *-winnt* ]] &&
		epatch "${FILESDIR}"/2.2.6a/${PN}-2.2.6a-winnt.patch
	epatch "${FILESDIR}"/2.2.6b/${PN}-2.2.6b-mint.patch
	epatch "${FILESDIR}"/2.2.6b/${PN}-2.2.6b-irix.patch
	epatch "${FILESDIR}"/2.4/${PN}-2.4.2-solaris-postdeps-no-dedup.patch

	# seems that libtool has to know about EPREFIX a little bit better,
	# since it fails to find prefix paths to search libs from, resulting in
	# some packages building static only, since libtool is fooled into
	# thinking that libraries are unavailable (argh...). This could also be
	# fixed by making the gcc wrapper return the correct result for
	# -print-search-dirs (doesn't include prefix dirs ...).
	if use prefix ; then
		epatch "${FILESDIR}"/2.2.10/${PN}-2.2.10-eprefix.patch
		eprefixify libltdl/m4/libtool.m4
	fi

	cd libltdl/m4
	epatch "${FILESDIR}"/1.5.20/${PN}-1.5.20-use-linux-version-in-fbsd.patch #109105
	epatch "${FILESDIR}"/2.2.6a/${PN}-2.2.6a-darwin-module-bundle.patch
	epatch "${FILESDIR}"/2.2.6a/${PN}-2.2.6a-darwin-use-linux-version.patch
	epatch "${FILESDIR}"/2.4/${PN}-2.4-interix.patch
	epatch "${FILESDIR}"/2.4/${PN}-2.4.2-solaris_sol2.patch
	cd ..
	AT_NOELIBTOOLIZE=yes eautoreconf
	cd ..
	AT_NOELIBTOOLIZE=yes eautoreconf
	epunt_cxx
}

src_configure() {
	# the libtool script uses bash code in it and at configure time, tries
	# to find a bash shell.  if /bin/sh is bash, it uses that.  this can
	# cause problems for people who switch /bin/sh on the fly to other
	# shells, so just force libtool to use /bin/bash all the time.
	export CONFIG_SHELL="$(type -P bash)"

	local myconf
	# usr/bin/libtool is provided by binutils-apple
	[[ ${CHOST} == *-darwin* ]] && myconf="--program-prefix=g"
	econf ${myconf} $(use_enable static-libs static) || die

	# Bootstrap host-libtool using this very $P.
	emake libtoolize || die
	cd "${WORKDIR}"/host-libtool || die

	local-libtoolize() {
		# tell libtoolize to use local input files
		_lt_pkgdatadir="${S}" "${S}"/libtoolize "$@"
	}

	AT_M4DIR="${S}"/libltdl/m4 \
	LIBTOOLIZE='local-libtoolize' \
	eautoreconf

	econf ${myconf} $(use_enable static-libs static) || die

	# Put the elibtoolize'd one in place. Actually, the installed libtool
	# script should be a separate package, maybe also useable as
	# ${CHOST}-libtool for cross-compiling. Keeping this one for now to
	# prevent the need for creating another sys-devel package in Prefix.
	cp libtool "${S}" || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog* NEWS README THANKS TODO doc/PLATFORMS

	# While the libltdl.la file is not used directly, the m4 ltdl logic
	# keys off of its existence when searching for ltdl support. #293921
	#use static-libs || find "${ED}" -name libltdl.la -delete

	# Building libtool with --disable-static will cause the installed
	# helper to not build static objects by default.  This is undesirable
	# for crappy packages that utilize the system libtool, so undo that.
	local g=
	[[ ${CHOST} == *-darwin* ]] && g=g
	dosed '1,/^build_old_libs=/{/^build_old_libs=/{s:=.*:=yes:}}' /usr/bin/${g}libtool || die

	local x
	for x in $(find "${ED}" -name config.guess -o -name config.sub) ; do
		ln -sf "${EPREFIX}"/usr/share/gnuconfig/${x##*/} "${x}" || die
	done
}

pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/libltdl$(get_libname 3)
}

pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/libltdl$(get_libname 3)
}
