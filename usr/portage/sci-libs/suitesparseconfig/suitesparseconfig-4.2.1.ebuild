# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/suitesparseconfig/suitesparseconfig-4.2.1.ebuild,v 1.2 2014/03/04 19:44:56 vincent Exp $

EAPI=5

inherit autotools-utils

DESCRIPTION="Common configurations for all packages in suitesparse"
HOMEPAGE="http://www.cise.ufl.edu/research/sparse/SuiteSparse_config"
SRC_URI="http://dev.gentoo.org/~bicatali/distfiles/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~mips ~ppc ~ppc64 ~sparc ~x86 ~amd64-fbsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="static-libs"

RDEPEND=""
DEPEND="${RDEPEND}"
