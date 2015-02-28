# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ml/pxp/pxp-1.2.3.ebuild,v 1.6 2013/03/06 12:01:54 aballier Exp $

EAPI="5"

inherit findlib eutils

MY_P=${P/_beta/test}

DESCRIPTION="validating XML parser library for O'Caml"
HOMEPAGE="http://projects.camlcity.org/projects/pxp.html"
SRC_URI="http://download.camlcity.org/download/${MY_P}.tar.gz"

LICENSE="MIT"
KEYWORDS="amd64 ~ppc x86"

SLOT="0/${PV}"
DEPEND=">=dev-ml/pcre-ocaml-4.31:=
>=dev-ml/ulex-0.5:=
>=dev-ml/ocamlnet-0.98:=
>=dev-lang/ocaml-3.10.2:=[ocamlopt?]"
RDEPEND="${DEPEND}"

IUSE="examples +ocamlopt"

S=${WORKDIR}/${MY_P}

src_configure() {
	#the included configure does not support  many standard switches and is quite picky
	./configure || die "configure failed"
}

src_compile() {
	emake -j1 all
	if use ocamlopt; then
		emake -j1 opt
	fi
}

src_install() {
	findlib_src_install
	if use examples; then
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi

	cd doc
	dodoc ABOUT-FINDLIB README SPEC design.txt
}
