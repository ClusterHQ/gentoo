# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/xvid/xvid-1.3.3.ebuild,v 1.5 2014/07/23 15:20:25 ago Exp $

EAPI=5
inherit flag-o-matic multilib multilib-minimal

MY_PN=${PN}core
MY_P=${MY_PN}-${PV}

DESCRIPTION="XviD, a high performance/quality MPEG-4 video de-/encoding solution"
HOMEPAGE="http://www.xvid.org/"
SRC_URI="http://downloads.xvid.org/downloads/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="examples elibc_FreeBSD +threads pic"

NASM=">=dev-lang/nasm-2"
YASM=">=dev-lang/yasm-1"

DEPEND="sys-apps/grep
	amd64? ( || ( ${YASM} ${NASM} ) )
	amd64-fbsd? ( ${NASM} )
	x86? ( || ( ${YASM} ${NASM} ) )
	x86-fbsd? ( ${NASM} )
	x86-macos? ( ${NASM} )
	x64-macos? ( ${NASM} )"
RDEPEND="abi_x86_32? ( !app-emulation/emul-linux-x86-medialibs[-abi_x86_32(-)] )"
RDEPEND=""

S=${WORKDIR}/${MY_PN}/build/generic

src_prepare() {
	# make build verbose
	sed \
		-e 's/@$(CC)/$(CC)/' \
		-e 's/@$(AS)/$(AS)/' \
		-e 's/@$(RM)/$(RM)/' \
		-e 's/@$(INSTALL)/$(INSTALL)/' \
		-e 's/@cd/cd/' \
		-i Makefile || die
	# Since only the build system is in $S, this will only copy it but not the
	# entire sources.
	multilib_copy_sources
}

multilib_src_configure() {
	use sparc && append-cflags -mno-vis #357149
	use elibc_FreeBSD && export ac_cv_prog_ac_yasm=no #477736

	local myconf
	if use pic || [[ ${ABI} == "x32" ]] ; then #421841
		myconf="--disable-assembly"
	fi
	# nasm (?) generates a symbol in the data iso text section, in any
	# case, linker doesn't find it
	[[ ${CHOST} == x86_64-*-darwin* ]] && myconf="--disable-assembly"

	econf \
		$(use_enable threads pthread) \
		${myconf}
}

#multilib_src_install() {
#	emake DESTDIR="${D}" install
#}

multilib_src_install_all() {
	dodoc "${S}"/../../{AUTHORS,ChangeLog*,CodingStyle,README,TODO}

	if use examples; then
		dodoc "${S}"/../../CodingStyle
		insinto /usr/share/${PN}
		doins -r "${S}"/../../examples
	fi
}
