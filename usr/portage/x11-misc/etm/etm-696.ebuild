# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/etm/etm-696.ebuild,v 1.3 2012/04/01 04:48:11 floppym Exp $

EAPI=3
PYTHON_DEPEND="2:2.5"
inherit distutils

DESCRIPTION="Event and Task Manager, an intuitive time management application"
HOMEPAGE="http://www.duke.edu/~dgraham/ETM/"
SRC_URI="mirror://sourceforge/etmeventandtask/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ical"

DEPEND="dev-python/wxpython:2.8
	dev-python/python-dateutil
	ical? ( dev-python/icalendar )"
RDEPEND="${DEPEND}"
RESTRICT_PYTHON_ABIS="2.4 3.*"
