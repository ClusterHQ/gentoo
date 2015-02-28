# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-dicts/myspell-lv/myspell-lv-1.0.0.ebuild,v 1.1 2014/07/04 01:34:13 mrueg Exp $

EAPI=5

MYSPELL_DICT=(
	"lv_LV.aff"
	"lv_LV.dic"
)

MYSPELL_HYPH=(
	"hyph_lv_LV.dic"
)

MYSPELL_THES=(
)

inherit myspell-r2

DESCRIPTION="Latvian dictionaries for myspell/hunspell"
HOMEPAGE="http://dict.dv.lv/home.php?prj=lv http://extensions.libreoffice.org/extension-center/latviesu-valodas-pareizrakstibas-parbaudes-modulis"
SRC_URI="http://dict.dv.lv/download/lv_LV-${PV}.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd"
IUSE=""
