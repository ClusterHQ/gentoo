# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/quilt/quilt-0.48.ebuild,v 1.7 2011/01/04 01:29:30 xmw Exp $

inherit bash-completion eutils

DESCRIPTION="quilt patch manager"
HOMEPAGE="http://savannah.nongnu.org/projects/quilt"
SRC_URI="http://savannah.nongnu.org/download/quilt/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="emacs graphviz"

RDEPEND="sys-apps/ed
	dev-util/diffstat
	graphviz? ( media-gfx/graphviz )
	|| ( >=sys-apps/coreutils-6.10-r1 sys-apps/mktemp )"

PDEPEND="emacs? ( app-emacs/quilt-el )"

pkg_setup() {
	use graphviz && return 0
	echo
	elog "If you intend to use the folding functionality (graphical illustration of the"
	elog "patch stack) then you'll need to remerge this package with USE=graphviz."
	echo
	epause 5
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Add support for USE=graphviz
	use graphviz || epatch "${FILESDIR}/${P}-no-graphviz.patch"

	# Some tests are somewhat broken while being run from within portage, work
	# fine if you run them manually
	rm "${S}"/test/delete.test "${S}"/test/mail.test
}

src_compile() {
	local myconf=""
	[[ ${CHOST} == *"-darwin"* ]] && myconf="${myconf} --without-getopt"
	econf ${myconf}
	emake
}

src_install() {
	emake BUILD_ROOT="${D}" install || die "make install failed"

	rm -rf "${ED}"/usr/share/doc/${P}
	dodoc AUTHORS TODO quilt.changes doc/README doc/README.MAIL \
		doc/quilt.pdf

	rm -rf "${ED}"/etc/bash_completion.d
	dobashcompletion bash_completion

	# Remove the compat symlinks
	rm -rf "${ED}"/usr/share/quilt/compat

	# Remove Emacs mode; newer version is in app-emacs/quilt-el, bug 247500
	rm -rf "${ED}"/usr/share/emacs
}
