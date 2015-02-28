# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/numactl/numactl-2.0.8-r1.ebuild,v 1.1 2013/04/20 04:15:52 vapier Exp $

EAPI="4"

inherit eutils toolchain-funcs multilib

DESCRIPTION="Utilities and libraries for NUMA systems"
HOMEPAGE="http://oss.sgi.com/projects/libnuma/"
SRC_URI="ftp://oss.sgi.com/www/projects/libnuma/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~amd64-linux"
IUSE="static-libs"

src_prepare() {
	echo "printf $(get_libdir)" > getlibdir
	epatch "${FILESDIR}"/${PN}-2.0.8-static_libs.patch
	epatch "${FILESDIR}"/${PN}-2.0.8-cpuid-pic.patch #456238
	rm numastat || die #466108
}

src_compile() {
	emake \
		AR="$(tc-getAR)" \
		CC="$(tc-getCC)" \
		RANLIB="$(tc-getRANLIB)" \
		CFLAGS="${CFLAGS}" \
		BENCH_CFLAGS="" \
		THREAD_SUPPORT=$(tc-has-tls && echo yes || echo no) \
		BUILD_STATIC=$(usex static-libs)
}

src_test() {
	if [ -d /sys/devices/system/node ]; then
		einfo "The only generically safe test is regress2."
		einfo "The other test cases require 2 NUMA nodes."
		cd test
		./regress2 || die
	else
		ewarn "You do not have baseline NUMA support in your kernel, skipping tests."
	fi
}

src_install() {
	emake install prefix="${ED}/usr" BUILD_STATIC=$(usex static-libs)
	# delete man pages provided by the man-pages package #238805
	rm -rf "${ED}"/usr/share/man/man[25]
	doman *.8 # makefile doesnt get them all
	dodoc README TODO CHANGES DESIGN
}
