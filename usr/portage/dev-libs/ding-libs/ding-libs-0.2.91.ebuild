# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/ding-libs/ding-libs-0.2.91.ebuild,v 1.2 2013/12/01 16:33:22 hwoarang Exp $

EAPI=4

inherit autotools-utils

DESCRIPTION="Library set needed for build sssd"
HOMEPAGE="https://fedorahosted.org/sssd"
SRC_URI="https://fedorahosted.org/released/${PN}/${P}.tar.gz"

LICENSE="LGPL-3 GPL-3"
SLOT="0"

KEYWORDS="~amd64 ~x86 ~amd64-linux"
IUSE="test static-libs"

#Obsolete blocks on old packages, to be removed soon
RDEPEND="!!dev-libs/libcollection
	!!dev-libs/libdhash
	!!dev-libs/libini_config
	!!dev-libs/libpath_utils
	!!dev-libs/libref_array"
DEPEND="${RDEPEND}
	test? ( dev-libs/check )"
