# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/haddock/haddock-2.6.1.ebuild,v 1.16 2013/02/10 14:26:06 slyfox Exp $

CABAL_FEATURES="bin lib"
# don't enable profiling as the 'ghc' package is not built with profiling
inherit eutils haskell-cabal autotools pax-utils

DESCRIPTION="A documentation-generation tool for Haskell libraries"
HOMEPAGE="http://www.haskell.org/haddock/"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 ia64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="doc"

# we bundle the dep on ghc-paths to reduce the dependencies on this critical
# package. ghc-paths would like to be compiled with USE=doc, which pulls in
# haddock, which requires ghc-paths, which pulls in haddock...

RDEPEND=">=dev-lang/ghc-6.12 <dev-lang/ghc-7"
DEPEND="${RDEPEND}
		>=dev-haskell/cabal-1.6
		doc? (  ~app-text/docbook-xml-dtd-4.2
				app-text/docbook-xsl-stylesheets
				>=dev-libs/libxslt-1.1.2 )"

src_unpack() {
	unpack ${A}

	# remove dependency on ghc-paths, we include it right into haddock instead
	sed -e "s|build-depends: ghc-paths|build-depends:|" \
		-i "${S}/${PN}.cabal"

	cd "${S}"
	epatch "${FILESDIR}"/${P}-cabal-1.8.patch

	# copy of slightly modified version of GHC.Paths
	mkdir "${S}/src/GHC"
	cp "${FILESDIR}/ghc-paths-1.0.5.0-GHC-Paths.hs" "${S}/src/GHC/Paths.hs"

	# a few things we need to replace, and example values
	# GHC_PATHS_LIBDIR /usr/lib64/ghc-6.12.0.20091010
	# GHC_PATHS_DOCDIR /usr/share/doc/ghc-6.12.0.20091010/html
	# GHC_PATHS_GHC_PKG /usr/bin/ghc-pkg
	# GHC_PATHS_GHC /usr/bin/ghc (be careful: GHC_PATHS_GHC is a substring of GHC_PATHS_GHC_PKG)

	# hardcode stuff above:
	sed \
	    -e "s|GHC_PATHS_LIBDIR|\"$(ghc-libdir)\"|" \
	    -e "s|GHC_PATHS_DOCDIR|\"/usr/share/doc/ghc-$(ghc-version)/html\"|" \
	    -e "s|GHC_PATHS_GHC_PKG|\"$(ghc-getghcpkg)\"|" \
	    -e "s|GHC_PATHS_GHC|\"$(ghc-getghc)\"|" \
	  -i "${S}/src/GHC/Paths.hs"

	if use doc; then
	  cd "${S}/doc"
	  eautoreconf
	fi

}

src_compile () {
	cabal_src_compile
	if use doc; then
		cd "${S}/doc"
		./configure --prefix="${D}/usr/" \
			|| die 'error configuring documentation.'
		emake html || die 'error building documentation.'
	fi
}

src_install () {
	cabal_src_install
	# haddock uses GHC-api to process TH source.
	# TH requires GHCi which needs mmap('rwx') (bug #299709)
	pax-mark -m "${D}/usr/bin/${PN}"

	if use doc; then
		dohtml -r "${S}/doc/haddock/"*
	fi
	dodoc CHANGES README
}
