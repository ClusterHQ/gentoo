# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/socat/socat-1.7.2.4-r1.ebuild,v 1.9 2014/07/20 09:16:05 klausman Exp $

EAPI=5

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="Multipurpose relay (SOcket CAT)"
HOMEPAGE="http://www.dest-unreach.org/socat/"
MY_P=${P/_beta/-b}
S="${WORKDIR}/${MY_P}"
SRC_URI="http://www.dest-unreach.org/socat/download/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="ssl readline ipv6 tcpd"

DEPEND="
	ssl? ( >=dev-libs/openssl-0.9.6 )
	readline? ( >=sys-libs/ncurses-5.1 >=sys-libs/readline-4.1 )
	tcpd? ( sys-apps/tcp-wrappers )
"
RDEPEND="${DEPEND}"

RESTRICT="test"

DOCS=(
	BUGREPORTS CHANGES DEVELOPMENT EXAMPLES FAQ FILES PORTING README SECURITY
)

src_configure() {
	filter-flags '-Wno-error*' #293324
	tc-export AR
	econf \
		$(use_enable ssl openssl) \
		$(use_enable readline) \
		$(use_enable ipv6 ip6) \
		$(use_enable tcpd libwrap)
}

src_install() {
	default

	dohtml doc/*.html doc/*.css
}
