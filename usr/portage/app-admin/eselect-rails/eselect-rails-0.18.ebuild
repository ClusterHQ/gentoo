# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-rails/eselect-rails-0.18.ebuild,v 1.8 2013/01/15 07:12:01 zerochaos Exp $

DESCRIPTION="Manages Ruby on Rails symlinks"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="http://dev.gentoo.org/~flameeyes/ruby-team/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~arm ppc ppc64 x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=app-admin/eselect-1.2.0"

src_unpack() {
	unpack ${A}
	# Fix/Add Prefix support
	sed -i -e 's/\${ROOT}/${EROOT}/' *.eselect || die
}

src_install() {
	insinto /usr/share/eselect/modules
	doins *.eselect || die "doins failed"
}
