# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/scikits/scikits-0.1.ebuild,v 1.5 2013/02/06 15:43:16 jlec Exp $

EAPI=4

SUPPORT_PYTHON_ABIS="1"

inherit python

DESCRIPTION="Common files for python scikits"
HOMEPAGE="http://projects.scipy.org/scipy/scikits"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}.example/${PN}.example-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="examples"

S="${WORKDIR}"

src_install() {
	install_scikits() {
		insinto $(python_get_sitedir)/scikits
		doins scikits.example*/scikits/__init__.py
	}
	python_execute_function -q install_scikits
	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r scikits.example*/*
	fi
}
