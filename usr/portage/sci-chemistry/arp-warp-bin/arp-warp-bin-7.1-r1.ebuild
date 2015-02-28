# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-chemistry/arp-warp-bin/arp-warp-bin-7.1-r1.ebuild,v 1.6 2013/02/06 07:55:47 jlec Exp $

EAPI=3

PYTHON_DEPEND="2"

inherit eutils prefix python

MY_P="arp_warp_${PV}"

DESCRIPTION="Software for improvement and interpretation of crystallographic electron density maps"
SRC_URI="${MY_P}.tar.gz"
HOMEPAGE="http://www.embl-hamburg.de/ARP/"

LICENSE="ArpWarp"
SLOT="0"
KEYWORDS="-* amd64 x86 ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="
	app-shells/tcsh
	sci-chemistry/refmac
	virtual/awk
	virtual/jre
	virtual/opengl
	x11-libs/libX11"
DEPEND=""

RESTRICT="fetch"

S="${WORKDIR}/${MY_P}"

QA_PREBUILT="opt/arp-warp-bin/bin/*"

pkg_nofetch(){
	elog "Fill out the form at http://www.embl-hamburg.de/ARP/"
	elog "and place ${A} in ${DISTDIR}"
}

pkg_setup() {
	python_set_active_version 2
}

src_prepare() {
	epatch "${FILESDIR}"/${PV}-setup.patch
	eprefixify "${S}"/share/arpwarp_setup_base.*
	sed "s:PYVER:$(python_get_version):g" -i "${S}"/share/arpwarp_setup_base.*
	python_convert_shebangs $(python_get_version) flex-wARP-src-354/*py
	sed -e "s:/usr/:${EPREFIX}/usr/:g" -i flex-wARP-src-354/*py || die
	sed -e '/exit/d' -i "${S}"/share/arpwarp_setup_base.* || die
}

src_install(){
	PYVER=$(python_get_version)
	m_type=$(uname -m)
	os_type=$(uname)

	insinto /opt/${PN}/byte-code/python-${PYVER}
	doins "${S}"/flex-wARP-src-354/*py || die

	exeinto /opt/${PN}/bin/bin-${m_type}-${os_type}
	doexe "${S}"/bin/bin-${m_type}-${os_type}/* && \
	doexe "${S}"/share/*sh || die

	insinto /opt/${PN}/bin/bin-${m_type}-${os_type}
	doins "${S}"/share/*{gif,bmp,XYZ,bash,csh,dat,lib,tbl,llh} || die

	insinto /etc/profile.d/
	newins "${S}"/share/arpwarp_setup_base.csh 90arpwarp_setup.csh && \
	newins "${S}"/share/arpwarp_setup_base.bash 90arpwarp_setup.sh || die

	dodoc "${S}"/README manual/UserGuide${PV}.pdf || die
	dohtml -r "${S}"/manual/html/* || die
}

pkg_postinst(){
	python_need_rebuild
	python_mod_optimize /opt/${PN}/byte-code/python-${PYVER}

	testcommand=$(echo 3 2 | awk '{printf"%3.1f",$1/$2}')
	if [ $testcommand == "1,5" ];then
	  ewarn "*** ERROR ***"
	  ewarn "   3/2=" $testcommand
	  ewarn "Invalid decimal separator (must be ".")"
	  ewarn "You need to set this correctly!!!"
	  echo
	  ewarn "One way of setting the decimal separator is:"
	  ewarn "setenv LC_NUMERIC C' in your .cshrc file"
	  ewarn "\tor"
	  ewarn "export LC_NUMERIC=C' in your .bashrc file"
	  ewarn "Otherwise please consult your system manager"
	fi

	grep -q sse2 /proc/cpuinfo || einfo "The CPU is lacking SSE2! You should use the cluster at EMBL-Hamburg."
	echo
}

pkg_postrm() {
	python_mod_cleanup /opt/${PN}/byte-code/python-${PYVER}
}
