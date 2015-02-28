# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/python-nbxmpp/python-nbxmpp-0.4-r1.ebuild,v 1.2 2014/06/20 14:09:14 klausman Exp $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1

TAG=4

DESCRIPTION="Python library to use Jabber/XMPP networks in a non-blocking way"
HOMEPAGE="http://python-nbxmpp.gajim.org/"
SRC_URI="http://python-nbxmpp.gajim.org/downloads/${TAG} -> ${P}.tar.gz"

SLOT="0"
LICENSE="BSD"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~x86 ~amd64-linux ~x86-linux"
IUSE=""

S="${WORKDIR}"/nbxmpp-${PV}

PATCHES=( "${FILESDIR}"/${P}-store-certificate-backport.patch )
