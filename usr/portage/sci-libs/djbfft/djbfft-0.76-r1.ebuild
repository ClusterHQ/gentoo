# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/djbfft/djbfft-0.76-r1.ebuild,v 1.9 2012/12/27 08:15:03 armin76 Exp $

EAPI=4
inherit eutils flag-o-matic toolchain-funcs multilib

DESCRIPTION="Extremely fast library for floating-point convolution"
HOMEPAGE="http://cr.yp.to/djbfft.html"
SRC_URI="http://cr.yp.to/djbfft/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="alpha amd64 arm ~hppa ppc ppc64 sh sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

src_prepare() {
	SOVER="${PV:0:1}.${PV:2:1}.${PV:3:1}" # a.bc -> a.b.c
	# mask out everything, which is not suggested by the author (RTFM)!
	ALLOWED_FLAGS="-fstack-protector -march -mcpu -pipe -mpreferred-stack-boundary -ffast-math"
	strip-flags

	use x86 && append-cflags -malign-double

	SONAME="libdjbfft.so.${SOVER}"

	epatch \
		"${FILESDIR}"/${P}-gcc3.patch \
		"${FILESDIR}"/${P}-shared.patch \
		"${FILESDIR}"/${P}-headers.patch

	sed -i -e "s:\"lib\":\"$(get_libdir)\":" hier.c || die
	echo "$(tc-getCC) ${CFLAGS} -fPIC" > "conf-cc"
	echo "$(tc-getCC) ${LDFLAGS}" > "conf-ld"
	echo "${ED}usr" > "conf-home"
	einfo "conf-cc: $(<conf-cc)"
}

src_compile() {
	emake \
		LIBDJBFFT=${SONAME} \
		LIBPERMS=0755 \
		${SONAME}
	echo "the compile function was:"
	cat ./compile
	echo "the conf-ld function was:"
	cat ./conf-ld
}

src_test() {
	local t
	for t in accuracy accuracy2 speed; do
		emake ${t}
		einfo "Testing ${t}"
		LD_LIBRARY_PATH=. ./${t} > ${t}.out || die "test ${t} failed"
	done
}

src_install() {
	emake LIBDJBFFT=${SONAME} install
	./install || die "install failed"
	dosym ${SONAME} /usr/$(get_libdir)/libdjbfft.so
	dosym ${SONAME} /usr/$(get_libdir)/libdjbfft.so.${SOVER%%.*}
	dodoc CHANGES README TODO VERSION
}
