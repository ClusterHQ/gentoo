# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-benchmarks/ramspeed/ramspeed-2.6.0.ebuild,v 1.5 2012/12/01 18:02:23 blueness Exp $

EAPI=2
inherit flag-o-matic toolchain-funcs

DESCRIPTION="Benchmarking for memory and cache"
HOMEPAGE="http://www.alasir.com/software/ramspeed/"
SRC_URI="http://www.alasir.com/software/${PN}/${P}.tar.gz"

LICENSE="Alasir"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="sse"

src_prepare(){
	tc-export CC AS
}

src_configure(){
	local obj
	local arch_prefix=./

	use x86 && arch_prefix=i386/
	use amd64 && arch_prefix=amd64/

	#fix the stack
	append-ldflags -Wl,-z,noexecstack
	obj=( ramspeed.o ${arch_prefix}{fltmark,fltmem,intmark,intmem}.o )

	if use x86; then
		obj=( "${obj[@]}" ${arch_prefix}{cpuinfo/cpuinfo_main,cpuinfo/cpuinfo_ext}.o )
	fi

	if use sse; then
		use x86 && append-flags "-DLINUX -DI386_ASM"
		use amd64 && append-flags "-DLINUX -DAMD64_ASM"
		obj=( "${obj[@]}" ${arch_prefix}{mmxmark,mmxmem,ssemark,ssemem}.o )
	fi

	echo "ramspeed: ${obj[@]}" > Makefile || die
}

src_install(){
	dobin ${PN} || die
	dodoc HISTORY README || die
}
