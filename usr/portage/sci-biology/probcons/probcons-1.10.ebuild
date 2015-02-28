# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/probcons/probcons-1.10.ebuild,v 1.3 2010/06/17 09:46:52 jlec Exp $

inherit eutils toolchain-funcs

MY_P="${PN}_v${PV/./_}"
DESCRIPTION="Probabilistic Consistency-based Multiple Alignment of Amino Acid Sequences"
HOMEPAGE="http://probcons.stanford.edu/"
SRC_URI="http://probcons.stanford.edu/${MY_P}.tar.gz"
LICENSE="public-domain"
SLOT="0"
KEYWORDS="x86"
IUSE=""
# Gnuplot is explicitly runtime-only, it's run using system()
RDEPEND="
	!sci-geosciences/gmt
	sci-visualization/gnuplot"
DEPEND=""
S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	epatch ${FILESDIR}/${PV}-fix-cxxflags.patch
}

src_compile() {
	emake \
		CXX="$(tc-getCXX)" \
		OPT_CXXFLAGS="${CXXFLAGS}" \
		|| die "make failed"
}

src_install() {
	DESTTREE="/usr" dobin probcons project makegnuplot
	# Overlap with imagemagick
	DESTTREE="/usr" newbin compare compare-probcons
	dodoc README
}

pkg_postinst() {
	ewarn "The 'compare' binary is installed as 'compare-probcons'"
	ewarn "to avoid overlap with other packages."
	einfo "You may also want to download the user manual"
	einfo "from http://probcons.stanford.edu/manual.pdf"
}
