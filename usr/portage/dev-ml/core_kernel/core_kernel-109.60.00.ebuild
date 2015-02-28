# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ml/core_kernel/core_kernel-109.60.00.ebuild,v 1.2 2014/01/19 19:40:00 zlogene Exp $

EAPI="5"

OASIS_BUILD_DOCS=1
OASIS_BUILD_TESTS=1

inherit oasis

DESCRIPTION="System-independent part of Core"
HOMEPAGE="http://www.janestreet.com/ocaml"
SRC_URI="http://ocaml.janestreet.com/ocaml-core/${PV}/individual/${P}.tar.gz
	http://dev.gentoo.org/~aballier/distfiles/${P}.tar.gz"

LICENSE="LGPL-2.1-with-linking-exception"
SLOT="0/${PV}"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="test"

RDEPEND="
	>=dev-ml/bin-prot-109.53.00:=
	>=dev-ml/comparelib-109.27.00:=
	>=dev-ml/fieldslib-109.20.00:=
	>=dev-ml/herelib-109.35.00:=
	>=dev-ml/pa_ounit-109.27.00:=
	>=dev-ml/pipebang-109.15.00:=
	>=dev-ml/sexplib-109.20.00:=
	>=dev-ml/variantslib-109.15.00:=
	dev-ml/pa_bench:=
	dev-ml/typerep:=
	!dev-ml/zero
	"
DEPEND="${RDEPEND}
	test? (
		dev-ml/pa_ounit
		>=dev-ml/core-109.60.00
	)"
DOCS=( "README.md" )
