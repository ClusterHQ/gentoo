# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-chemistry/dssp/dssp-0.70831.ebuild,v 1.1 2012/06/13 11:01:40 jlec Exp $

EAPI="2"

inherit toolchain-funcs flag-o-matic

DESCRIPTION="The protein secondary structure standard"
HOMEPAGE="http://swift.cmbi.ru.nl/gv/dssp/"
#SRC_URI="ftp://ftp.cmbi.ru.nl/pub/molbio/software/dsspcmbi.tar.gz"
SRC_URI="${P/./}cmbi.tar.gz"

LICENSE="free-noncomm"
SLOT="0"
KEYWORDS="amd64 x86 ~amd64-linux ~x86-linux"
IUSE=""
RESTRICT="fetch"

S="${WORKDIR}"/${PN}

pkg_nofetch() {
	elog "Download ftp://ftp.cmbi.ru.nl/pub/molbio/software/dsspcmbi.tar.gz --"
	elog "Rename it to ${A} and place it in ${DISTDIR}"
}

src_prepare() {
	cp "${FILESDIR}"/Makefile .
	append-flags -DGCC
}

src_compile() {
	emake CC="$(tc-getCC)" || die
}

src_install() {
	dobin dssp || die
	dodoc README.TXT || die
	dohtml index.html || die
}

pkg_postinst() {
	elog "Go to ${HOMEPAGE} and return the license agreement."
	elog "One of its requirements is citing the article:"
	elog "Kabsch, W. & Sander, C. Biopolymers 22:2577-2637 (1983)."
}
