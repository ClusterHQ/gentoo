# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/moe/moe-1.5.ebuild,v 1.4 2013/06/07 13:05:32 zlogene Exp $

EAPI=5

inherit eutils toolchain-funcs

DESCRIPTION="A powerful and user-friendly console text editor"
HOMEPAGE="http://www.gnu.org/software/moe/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm x86 ~amd64-linux ~x86-linux"

DEPEND="sys-libs/ncurses"
RDEPEND="${DEPEND}"

src_prepare() {
	tc-export CXX
	sed -i \
		-e "/^CXXFLAGS=/d" \
		-e "/^LDFLAGS=/d" \
		-e  "/^CXX=/d" \
		configure || die "sed on configure failed"

	epatch_user
}
