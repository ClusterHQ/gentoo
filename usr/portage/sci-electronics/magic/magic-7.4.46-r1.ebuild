# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-electronics/magic/magic-7.4.46-r1.ebuild,v 1.7 2014/08/10 20:28:13 slyfox Exp $

DESCRIPTION="The VLSI design CAD tool"
HOMEPAGE="http://www.opencircuitdesign.com/magic/index.html"
SRC_URI="http://www.opencircuitdesign.com/magic/archive/${P}.tgz \
	ftp://ftp.mosis.edu/pub/sondeen/magic/new/beta/2002a.tar.gz"

LICENSE="HPND GPL-2+"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE=""

RDEPEND="sys-libs/ncurses
	sys-libs/readline
	dev-lang/tcl
	dev-lang/tk
	dev-tcltk/blt"
DEPEND="${RDEPEND}
	app-shells/tcsh"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# bug 281148 - tcl-8.5
	sed -i -e 's/package require -exact Tk/package require Tk/g' \
		tcltk/tkcon.tcl
}

src_compile() {
	# Short-circuit top-level configure script to retain CFLAGS
	cd scripts
	CPP="cpp" econf --libdir=/usr/share
	cd ..
	emake -j1 || die "Compilation failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "Installation failed"
	dodoc README README.Tcl TODO

	# Install latest MOSIS tech files
	cp -pPR "${WORKDIR}"/2002a "${D}"/usr/share/magic/sys/current
}

pkg_postinst() {
	ewarn 'Magic now uses "~/.magicrc" as the personal startup file rather'
	ewarn 'than "~/.magic" or the previously Gentoo specific "~/.magic-cad".'
}
