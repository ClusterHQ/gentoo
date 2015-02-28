# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-strategy/xconq/xconq-7.4.1.ebuild,v 1.16 2010/10/13 23:47:25 mr_bones_ Exp $

EAPI=2
inherit eutils games

DESCRIPTION="a general strategy game system"
HOMEPAGE="http://sources.redhat.com/xconq/"
SRC_URI="ftp://sources.redhat.com/pub/xconq/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE=""
RESTRICT="test"

DEPEND="x11-libs/libXmu
	x11-libs/libXaw
	dev-lang/tk
	dev-lang/tcl"

PATCHES=( "${FILESDIR}"/${PN}-gcc-3.4.patch
		  "${FILESDIR}"/${PN}-tkconq.patch
		  "${FILESDIR}"/${PN}-make-382.patch
		)

src_configure() {
	egamesconf \
		--enable-alternate-scoresdir="${GAMES_STATEDIR}"/${PN}
}

src_compile() {
	emake \
		CFLAGS="${CFLAGS}" \
		LDFLAGS="${LDFLAGS}" \
		datadir="${GAMES_DATADIR}"/${PN} \
		|| die "emake failed"
}

src_install() {
	dogamesbin x11/{imf2x,x2imf,xconq,ximfapp} || die "dogamesbin failed"

	insinto "${GAMES_DATADIR}"/${PN}
	doins -r images lib tcltk/*.tcl || die "doins failed"
	rm -f "${D}/${GAMES_DATADIR}"/${PN}/{images,lib}/{m,M}ake*

	dodir "${GAMES_STATEDIR}"/${PN}
	touch "${D}/${GAMES_STATEDIR}"/${PN}/scores.xcq
	fperms 660 "${GAMES_STATEDIR}"/${PN}/scores.xcq || die

	doman x11/${PN}.6
	dodoc ChangeLog NEWS README
	prepgamesdirs
}
