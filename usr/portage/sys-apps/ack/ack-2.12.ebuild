# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/ack/ack-2.12.ebuild,v 1.4 2014/06/19 08:36:20 klausman Exp $

EAPI=5
MODULE_AUTHOR=PETDANCE
inherit perl-module

DESCRIPTION="ack is a tool like grep, aimed at programmers with large trees of heterogeneous source code"
HOMEPAGE="http://betterthangrep.com/ ${HOMEPAGE}"

LICENSE="Artistic-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~hppa x86 ~x86-interix ~amd64-linux ~x86-linux ~x86-macos"
IUSE="test"

RDEPEND=">=dev-perl/File-Next-1.100.0"
DEPEND="${RDEPEND}"

SRC_TEST=do
PATCHES=( "${FILESDIR}"/${PN}-2.04-gentoo.patch )

src_test() {
	# Tests fail when run in parallel and if dev-perl/IO-Tty is installed
	# which enables interactive tests that need to read from stdin. If IO-Tty
	# is not installed the related tests are skipped.
	MAKEOPTS+=" -j1" perl-module_src_test
}
