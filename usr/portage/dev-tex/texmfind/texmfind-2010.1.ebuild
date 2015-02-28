# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tex/texmfind/texmfind-2010.1.ebuild,v 1.5 2012/04/17 17:29:54 nativemad Exp $

inherit eutils prefix

DESCRIPTION="Locate the ebuild providing a certain texmf file through regexp"
HOMEPAGE="https://launchpad.net/texmfind/
	http://home.gna.org/texmfind"
SRC_URI="http://launchpad.net/texmfind/2010/${PV}/+download/texmfind-${PV}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="kernel_Darwin? ( app-misc/getopt )"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${WORKDIR}"

	epatch "${FILESDIR}"/${PN}-0.1-getopt.patch
	epatch "${FILESDIR}"/${PN}-0.1-prefix.patch
	eprefixify texmfind
}

src_install() {
	emake DESTDIR="${D}" install || die
}
