# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/killproc/killproc-2.13-r1.ebuild,v 1.5 2014/08/26 09:41:25 kumba Exp $

EAPI=5
inherit eutils toolchain-funcs

DESCRIPTION="killproc and assorted tools for boot scripts"
HOMEPAGE="http://www.suse.de/"
SRC_URI="ftp://ftp.suse.com/pub/projects/init/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86"

src_prepare() {
	epatch "${FILESDIR}/${P}-makefile.patch"
	tc-export CC
	export COPTS=${CFLAGS}
}

src_install() {
	into /
	dosbin checkproc fsync killproc startproc usleep
	into /usr
	doman *.8 *.1
	dodoc README *.lsm
}
