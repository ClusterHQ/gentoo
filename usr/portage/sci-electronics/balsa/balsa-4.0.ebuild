# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-electronics/balsa/balsa-4.0.ebuild,v 1.3 2012/04/25 17:22:35 jlec Exp $

EAPI="1"

inherit autotools eutils multilib toolchain-funcs

DESCRIPTION="The Balsa asynchronous synthesis system"
HOMEPAGE="http://www.cs.manchester.ac.uk/apt/projects/tools/balsa/"
SRC_URI="
	ftp://ftp.cs.man.ac.uk/pub/amulet/balsa/${PV}/${P}.tar.gz
	ftp://ftp.cs.man.ac.uk/pub/amulet/balsa/${PV}/${PN}-sim-verilog-${PV}.tar.gz
	ftp://ftp.cs.man.ac.uk/pub/amulet/balsa/${PV}/${PN}-tech-example-${PV}.tar.gz
	ftp://ftp.cs.man.ac.uk/pub/amulet/balsa/${PV}/${PN}-tech-xilinx-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~ppc"
IUSE=""

DEPEND="
	dev-lang/perl
	dev-libs/gmp
	sci-electronics/gplcver
	sci-electronics/iverilog
	x11-libs/gtk+:2"
RDEPEND="${DEPEND}
	dev-scheme/guile
	media-gfx/graphviz
	sci-electronics/espresso-ab
	sci-electronics/gtkwave	"

BALSA_TECH_AMS="balsa-tech-ams-20030506.tar.gz"

if [ -f "${DISTDIR}"/${BALSA_TECH_AMS} ]; then
	TECH_AMS=1
fi

src_unpack() {
	unpack ${A}
	if [ $TECH_AMS ]; then
		unpack ${BALSA_TECH_AMS}
	fi
	cd "${S}"
	epatch "${FILESDIR}"/${PV}-libdir.patch
	epatch "${FILESDIR}"/${PV}-datadir.patch
	epatch "${FILESDIR}"/${PV}-ldflags.patch
	eautoreconf
	sed -i -e "s:\(DEFAULT_INCLUDES = \)\(.*\):\1-I${S}/src/libs/ \2/:" "${WORKDIR}"/balsa-sim-verilog-${PV}/libs/Makefile.in
	sed -i -e 's/ $(bindir)/ $(DESTDIR)$(bindir)/' "${S}"/bin/Makefile.in
	sed -i -e 's/ $(balsatypesdir)/ $(DESTDIR)$(balsatypesdir)/' "${S}"/share/balsa/types/Makefile.in
	sed -i -e 's/ $(balsasimdir)/ $(DESTDIR)$(balsasimdir)/' "${S}"/share/balsa/sim/Makefile.in
}

src_compile() {
	tc-export CXX
	# compile balsa
	einfo "Compiling balsa"
	econf
	chmod +x bin/balsa-config
	PATH="$PATH:"${S}"/bin"
	emake -j1 || die

	# configure AMS035 tech
	if [ $TECH_AMS ]; then
		einfo "Compiling AMS035 tech"
		cd "${WORKDIR}"/balsa-tech-ams-20030506
		econf
	fi

	# config Xilinx FPGA backend
	einfo "Compiling Xilinx FPGA backend"
	cd "${WORKDIR}"/balsa-tech-xilinx-${PV}
	econf

	# config example tech
	einfo "Compiling tech example"
	cd "${WORKDIR}"/balsa-tech-example-${PV}
	econf

	# config verilog simulator wrappers
	einfo "Compiling verilog simulator wrappers"
	cd "${WORKDIR}"/balsa-sim-verilog-${PV}
#	./configure --includedir="${S}"/src/libs/balsasim \
	econf \
		--includedir="${S}"/src/libs/balsasim \
		--with-icarus-includes=/usr/include \
		--with-icarus-libs=/usr/$(get_libdir) \
		--with-cver-includes=/usr/include/cver_pli_incs
}

src_install() {
	# install balsa
	emake DESTDIR="${D}" install || die

	if [ $TECH_AMS ]; then
		einfo "Installing AMS035 tech"
		cd "${WORKDIR}"/balsa-tech-ams-20030506
		emake DESTDIR="${D}" install || die "make install failed"
	fi

	einfo "Installing Xilinx FPGA tech"
	cd "${WORKDIR}"/balsa-tech-xilinx-${PV}
	emake DESTDIR="${D}" install || die "make install failed"

	einfo "Installing example tech"
	cd "${WORKDIR}"/balsa-tech-example-${PV}
	emake DESTDIR="${D}" install || die "make install failed"

	einfo "Installing verilog simulator wrappers"
	cd "${WORKDIR}"/balsa-sim-verilog-${PV}
	DESTDIR="${D}" emake install || die "make verilog wrappers failed"

	# fix paths
	cd "${D}"
	einfo "Fixing paths"
	find . -type f -exec sed -i -e "s:${D}::" {} \;
	find . -name "sed*" -exec rm -f {} \;

	# add some docs
	cd "${S}"
	dodoc AUTHORS NEWS README TODO || die

	# fix collisions
	rm -f "${D}"/usr/bin/libtool || die
}

pkg_postinst() {
	if [ ! $TECH_AMS ]; then
		elog "The AMS035 tech library was not installed."
		elog "If you have the appropriate licenses request"
		elog "the tech support files directly from balsa@cs.man.ac.uk"
		elog "and add them to /usr/portage/distfiles before emerging."
	else
		elog "The AMS035 tech library was found and installed."
	fi
}
