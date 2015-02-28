# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/treeline/treeline-1.9.4.ebuild,v 1.2 2014/08/10 20:04:08 slyfox Exp $

EAPI=5

PYTHON_COMPAT=( python3_3 )
PYTHON_REQ_USE="xml"

inherit eutils python-single-r1

DESCRIPTION="TreeLine is a structured information storage program"
HOMEPAGE="http://treeline.bellz.org/"
SRC_URI="mirror://sourceforge/project/${PN}/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

DEPEND="
	${PYTHON_DEPS}
"
RDEPEND="
	${DEPEND}
	dev-python/PyQt4[X,${PYTHON_USEDEP}]
"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

S="${WORKDIR}/TreeLine"

src_prepare() {
	rm doc/LICENSE || die

	python_export PYTHON_SITEDIR
	sed -i "s;prefixDir, 'lib;'${PYTHON_SITEDIR};" install.py || die
}

src_install() {
	"${EPYTHON}" install.py -x -p /usr/ -d /usr/share/doc/${PF} -b "${D}" || die
}
