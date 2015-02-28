# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/unpaper/unpaper-0.4.2.ebuild,v 1.1 2012/06/22 21:30:51 flameeyes Exp $

EAPI=4

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="git://github.com/Flameeyes/unpaper.git"
	inherit git-2 autotools
else
	SRC_URI="http://www.flameeyes.eu/files/${P}.tar.xz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Post-processor for scanned and photocopied book pages"
HOMEPAGE="http://www.flameeyes.eu/projects/unpaper"

LICENSE="GPL-2"

SLOT="0"
IUSE="test"

DEPEND="test? ( media-libs/netpbm[png] )
	dev-libs/libxslt
	app-text/docbook-xsl-ns-stylesheets"
RDEPEND=""

if [[ ${PV} == 9999 ]]; then
	src_prepare() {
		eautoreconf
	}
fi

src_configure() {
	econf \
		--docdir=/usr/share/doc/${PF} \
		--htmldir=/usr/share/doc/${PF}/html
}

src_test() {
	emake check
}
