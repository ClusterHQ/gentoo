# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-chemistry/ccp4i/ccp4i-6.1.3-r3.ebuild,v 1.8 2014/01/06 15:05:37 jlec Exp $

EAPI=3

PYTHON_DEPEND="2"

inherit eutils multilib python virtualx

MY_PN="${PN%i}"
MY_P="${MY_PN}-${PV}"

#UPDATE="04_03_09"
#PATCHDATE="090511"

SRC="ftp://ftp.ccp4.ac.uk/ccp4"

DESCRIPTION="Protein X-ray crystallography toolkit -- graphical interface"
HOMEPAGE="http://www.ccp4.ac.uk/"
SRC_URI="
	${SRC}/${PV}/${MY_P}-core-src.tar.gz
	mirror://gentoo/${P}-arpwarp.patch.bz2
	http://dev.gentooexperimental.org/~jlec/distfiles/${PV}-oasis4.0.patch.bz2"
[[ -n ${UPDATE} ]] && SRC_URI="${SRC_URI} ${SRC}/${PV}/updates/${P}-src-patch-${UPDATE}.tar.gz"
[[ -n ${PATCHDATE} ]] && SRC_URI="${SRC_URI} http://dev.gentooexperimental.org/~jlec/science-dist/${PV}-${PATCHDATE}-updates.patch.bz2"

SLOT="0"
KEYWORDS="amd64 ~ppc x86 ~amd64-linux ~x86-linux"
LICENSE="ccp4"
IUSE=""

RDEPEND="
	app-shells/tcsh
	media-gfx/graphviz
	>=dev-lang/tk-8.3
	>=dev-tcltk/blt-2.4
	sci-libs/ccp4-libs"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}"/${PV}-fix-baubles.patch
	"${WORKDIR}"/${P}-arpwarp.patch
	)

pkg_setup() {
	python_set_active_version 2
}

src_prepare() {
	epatch ${PATCHES[@]}

	[[ ! -z ${PATCHDATE} ]] && epatch "${WORKDIR}"/${PV}-${PATCHDATE}-updates.patch

	epatch "${WORKDIR}"/${PV}-oasis4.0.patch
	python_convert_shebangs -r $(python_get_version) ccp4i/ share/dbccp4i/
}

src_configure() {
	:
}

src_compile() {
	:
}

src_install() {
	# rm imosflm stuff
	rm -rf "${S}"/ccp4i/{bin/imosflm,imosflm}

	rm -rf "${S}"/ccp4i/{bin,etc}/WINDOWS

	# This is installed by mrbump
	rm -rf "${S}"/ccp4i/{tasks/{dbviewer.tcl,mrbump.*},templates/mrbump.com,scripts/mrbump.script}

	# CCP4Interface - GUI
	insinto /usr/$(get_libdir)/ccp4
	doins -r "${S}"/ccp4i || die
	exeinto /usr/$(get_libdir)/ccp4/ccp4i/bin
	doexe "${S}"/ccp4i/bin/* || die
	dosym ../$(get_libdir)/ccp4/ccp4i/bin/ccp4i /usr/bin/ccp4i

	dodir /usr/$(get_libdir)/ccp4/ccp4i/unix

	# dbccp4i
	insinto /usr/share/ccp4
	doins -r "${S}"/share/dbccp4i || die
}

pkg_postinst() {
	_ccp4-setup() {
		source "${EPREFIX}/etc/profile"
		export USER=root
		bash "${EPREFIX}"/usr/$(get_libdir)/ccp4/ccp4i/bin/ccp4i -h > /dev/null
	}
	VIRTUALX_COMMAND="_ccp4-setup" virtualmake
	echo ""
	elog "ccp4i needs some enviromental settings. So please"
	elog "\t source ${EPREFIX}/etc/profile"
	echo ""
}
