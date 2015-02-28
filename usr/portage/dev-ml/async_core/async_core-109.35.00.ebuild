# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ml/async_core/async_core-109.35.00.ebuild,v 1.1 2013/08/01 14:24:18 aballier Exp $

EAPI="5"

OASIS_BUILD_DOCS=1

inherit oasis

MY_P=${PN/-/_}-${PV}
DESCRIPTION="Jane Street Capital's asynchronous execution library (core)"
HOMEPAGE="http://www.janestreet.com/ocaml"
SRC_URI="http://ocaml.janestreet.com/ocaml-core/${PV}/individual/${MY_P}.tar.gz
	http://dev.gentoo.org/~aballier/distfiles/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0/${PV}"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=dev-lang/ocaml-4.00.0:=
	>=dev-ml/sexplib-109.20.00:=
	>=dev-ml/pa_ounit-109.27.00:=
	>=dev-ml/fieldslib-109.20.00:=
	>=dev-ml/bin-prot-109.15.00:=
	>=dev-ml/core-109.35.00:=
	>=dev-ml/herelib-109.35.00:=
	"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"
