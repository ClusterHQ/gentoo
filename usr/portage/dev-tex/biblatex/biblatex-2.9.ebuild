# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tex/biblatex/biblatex-2.9.ebuild,v 1.1 2014/05/29 12:09:27 mrueg Exp $

EAPI=5

inherit latex-package

DESCRIPTION="Reimplementation of the bibliographic facilities provided by LaTeX"
HOMEPAGE="http://www.ctan.org/tex-archive/macros/latex/contrib/biblatex"
SRC_URI="mirror://sourceforge/${PN}/${P}.tds.tgz"

LICENSE="LPPL-1.3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples"

RDEPEND="dev-texlive/texlive-bibtexextra"
DEPEND="${RDEPEND}"

S=${WORKDIR}
TEXMF=/usr/share/texmf-site

src_install() {
	insinto "${TEXMF}"
	doins -r bibtex tex

	dodoc doc/latex/biblatex/{README,RELEASE}
	use doc && { pushd doc/latex/biblatex/ ; latex-package_src_doinstall doc ; popd ; }
	if use examples ; then
		docinto examples
		dodoc -r doc/latex/biblatex/examples
	fi
}
