# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/vdkbuilder/vdkbuilder-2.4.0.ebuild,v 1.11 2014/08/10 21:29:47 slyfox Exp $

inherit eutils

MY_P=${PN}2-${PV}

DESCRIPTION="The Visual Development Kit used for VDK Builder"
HOMEPAGE="http://vdkbuilder.sf.net"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="ppc sparc x86"
IUSE="nls debug"

RDEPEND=">=dev-libs/vdk-2.4.0"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

custom_cflags() {
	for files in *
	do
		if [ -e ${files}/Makefile ]
		then
			sed -e "s/CFLAGS = .*/CFLAGS = ${CFLAGS} -I../include/" -i ${files}/Makefile
			sed -e "s/CXXFLAGS = .*/CFLAGS = ${CXXFLAGS} -I../include/" -i ${files}/Makefile
		fi
	done
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-make-382.patch
}

src_compile() {
	local myconf=""

	use debug \
		&& myconf="${myconf} --enable-devel=yes" \
		|| myconf="${myconf} --enable-devel=no"

	econf \
		$(use_enable nls) \
		--disable-vdktest \
		${myconf} || die "econf failed"

	custom_cflags

	emake -j1 || die
}

src_install () {
	einstall || die
	dodoc AUTHORS BUGS ChangeLog NEWS README TODO
}
