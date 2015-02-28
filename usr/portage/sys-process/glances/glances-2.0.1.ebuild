# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/glances/glances-2.0.1.ebuild,v 1.1 2014/07/07 14:49:56 idella4 Exp $

EAPI=5

PYTHON_COMPAT=( python{2_7,3_2,3_3,3_4} )
PYTHON_REQ_USE="ncurses"

inherit distutils-r1 linux-info

MYPN=Glances
MYP=${MYPN}-${PV}

DESCRIPTION="CLI curses based monitoring tool"
HOMEPAGE="https://github.com/nicolargo/glances"
SRC_URI="mirror://pypi/${MYPN:0:1}/${MYPN}/${MYP}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86 ~amd64-linux ~x86-linux"
IUSE="doc hddtemp snmp web"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
# There is another optional extra batinfo, absent from portage
RDEPEND="${DEPEND}
	>=dev-python/psutil-2.0.0[${PYTHON_USEDEP}]
	hddtemp? ( app-admin/hddtemp )
	snmp? ( dev-python/pysnmp[${PYTHON_USEDEP}] )
	web? ( dev-python/bottle[${PYTHON_USEDEP}] )"

CONFIG_CHECK="~TASK_IO_ACCOUNTING ~TASK_DELAY_ACCT ~TASKSTATS"

S="${WORKDIR}/${MYP}"

pkg_setup() {
	linux-info_pkg_setup
}

python_prepare_all() {
	sed -e "s:share/doc/glances:share/doc/${PF}:g" \
		-e "s/'COPYING',//" \
		-e "s:/etc:${EPREFIX}/etc:" \
		-i setup.py || die
	distutils-r1_python_prepare_all
}

python_install_all() {
	distutils-r1_python_install_all
	if use doc; then
		mkdir "${D}"usr/share/doc/${P}/html || die
		mv "${D}"usr/share/doc/${P}/{glances-doc.html,images/} "${D}"usr/share/doc/${P}/html/ || die
	else
		rm -rf "${D}"usr/share/doc/${P}/{glances-doc.html,images/} || die
	fi
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "${PN} can gain additional functionality with following packages:"
		elog "   dev-python/jinja - export statistics to HTML"
		elog "   app-admin/hddtemp - monitor hard drive temperatures"
	fi
}
