# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/flex/flex-2.5.37.ebuild,v 1.15 2014/01/18 03:14:16 vapier Exp $

EAPI="3"

inherit eutils flag-o-matic toolchain-funcs

if [[ ${PV} == *_p* ]] ; then
	DEB_DIFF=${PN}_${PV/_p/-}
fi
MY_P=${P%_p*}

DESCRIPTION="The Fast Lexical Analyzer"
HOMEPAGE="http://flex.sourceforge.net/"
SRC_URI="mirror://sourceforge/flex/${MY_P}.tar.bz2
	${DEB_DIFF:+mirror://debian/pool/main/f/flex/${DEB_DIFF}.diff.gz}"

LICENSE="FLEX"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static test"

# We want bison explicitly and not yacc in general #381273
RDEPEND="sys-devel/m4"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	test? ( sys-devel/bison )"

S=${WORKDIR}/${MY_P}

src_prepare() {
	[[ -n ${DEB_DIFF} ]] && epatch "${WORKDIR}"/${DEB_DIFF}.diff
	[[ ${CHOST} == *-mint* ]] && epatch "${FILESDIR}"/${PN}-2.5.35-mint.patch

	epatch "${FILESDIR}"/${P}-proto.patch
	epatch "${FILESDIR}"/${P}-tests.patch #429954
	epatch "${FILESDIR}"/${P}-rpl_alloc.patch #endless loop
	sed -i "/^AR =/s:=.*:= $(tc-getAR):" Makefile.in || die #444086
}

src_configure() {
	use static && append-ldflags -static
	econf \
		$(use_enable nls) \
		--docdir="${EPREFIX}"/usr/share/doc/${PF}
}

src_install() {
	emake install DESTDIR="${D}" || die
	rm "${ED}"/usr/share/doc/${PF}/{COPYING,flex.pdf} || die
	dodoc AUTHORS ChangeLog NEWS ONEWS README* THANKS TODO
	dosym flex /usr/bin/lex
}
