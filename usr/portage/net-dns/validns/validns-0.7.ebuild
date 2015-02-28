# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dns/validns/validns-0.7.ebuild,v 1.1 2013/08/12 11:37:10 wschlich Exp $

EAPI=4

DESCRIPTION="A high performance DNS/DNSSEC zone validator"
HOMEPAGE="http://www.validns.net/"
SRC_URI="http://www.validns.net/download/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-libs/judy"
DEPEND="
	${RDEPEND}
	test? ( dev-perl/Test-Command-Simple )
"

src_install() {
	dobin validns
	doman validns.1
	dodoc {notes,technical-notes,todo,usage}.mdwn Changes README
}
