# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/python-nbxmpp/python-nbxmpp-0.5.ebuild,v 1.1 2014/07/09 12:33:09 jlec Exp $

EAPI=5

PYTHON_COMPAT=( python{2_7,3_3,3_4} )

inherit distutils-r1

TAG=5

DESCRIPTION="Python library to use Jabber/XMPP networks in a non-blocking way"
HOMEPAGE="http://python-nbxmpp.gajim.org/"
SRC_URI="http://python-nbxmpp.gajim.org/downloads/${TAG} -> ${P}.tar.gz"

SLOT="0"
LICENSE="BSD"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~x86 ~amd64-linux ~x86-linux"
IUSE=""

S="${WORKDIR}"/nbxmpp-${PV}
