# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/haskell-platform/haskell-platform-2011.4.0.0.ebuild,v 1.1 2012/06/03 04:40:19 gienah Exp $

EAPI=4

DESCRIPTION="The Haskell Platform"
HOMEPAGE="http://haskell.org/platform"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="profile X"

RDEPEND=">=dev-haskell/cgi-3001.1.7.4[profile?]
		>=dev-haskell/deepseq-1.1.0.2[profile?]
		>=dev-haskell/fgl-5.4.2.4[profile?]
		>=dev-haskell/haskell-src-1.0.1.4[profile?]
		>=dev-haskell/html-1.0.1.2[profile?]
		>=dev-haskell/http-4000.1.2[profile?]
		>=dev-haskell/hunit-1.2.4.2[profile?]
		>=dev-haskell/mtl-2.0.1.0[profile?]
		>=dev-haskell/network-2.3.0.5[profile?]
		>=dev-haskell/parallel-3.1.0.1[profile?]
		>=dev-haskell/parsec-3.1.1[profile?]
		>=dev-haskell/quickcheck-2.4.1.1[profile?]
		>=dev-haskell/regex-base-0.93.2[profile?]
		>=dev-haskell/regex-compat-0.95.1[profile?]
		>=dev-haskell/regex-posix-0.95.1[profile?]
		>=dev-haskell/stm-2.2.0.1[profile?]
		>=dev-haskell/syb-0.3.3[profile?]
		>=dev-haskell/text-0.11.1.5[profile?]
		>=dev-haskell/transformers-0.2.2.0[profile?]
		>=dev-haskell/xhtml-3000.2.0.4[profile?]
		>=dev-haskell/zlib-0.5.3.1[profile?]
		X? (
			>=dev-haskell/opengl-2.2.3.0[profile?]
			>=dev-haskell/glut-2.1.2.1[profile?]
		)
		>=dev-lang/ghc-7.0.4

		>=dev-haskell/alex-2.3.5
		>=dev-haskell/cabal-1.10.2.0
		>=dev-haskell/happy-1.18.6
		>=dev-haskell/cabal-install-0.10.2
		>=dev-haskell/hscolour-1.17
		>=dev-haskell/haddock-2.9.2"

DEPEND="${RDEPEND}"

pkg_postinst() {
	if ! use X; then
		elog "The haskell platform includes the 3D graphics libraries opengl and glut."
		elog "To install opengl and glut requires the X use flag."
	fi
}
