# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/btf/btf-1.2.0.ebuild,v 1.2 2013/06/24 23:00:02 bicatali Exp $

EAPI=5

inherit autotools-utils

DESCRIPTION="Algorithm for matrix permutation into block triangular form"
HOMEPAGE="http://www.cise.ufl.edu/research/sparse/btf/"
SRC_URI="http://dev.gentoo.org/~bicatali/distfiles/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"

KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~ppc64 ~sparc ~x86 ~amd64-fbsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="static-libs"

RDEPEND="sci-libs/suitesparseconfig"
DEPEND="${RDEPEND}
	virtual/pkgconfig"
