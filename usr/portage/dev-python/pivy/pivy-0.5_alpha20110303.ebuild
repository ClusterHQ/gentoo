# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pivy/pivy-0.5_alpha20110303.ebuild,v 1.8 2013/04/27 12:02:32 xmw Exp $

EAPI="3"

SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.* 2.7-pypy-* *-jython"

inherit distutils

DESCRIPTION="Coin3d binding for Python"
HOMEPAGE="http://pivy.coin3d.org/"
SRC_URI="http://dev.gentoo.org/~dilfridge/distfiles/${P}.tar.xz"
#identical to latest debian tarball at 
# http://ftp.de.debian.org/debian/pool/main/p/pivy/pivy_0.5.0~v609hg.orig.tar.bz2

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	media-libs/coin
	>=media-libs/SoQt-1.5.0"
DEPEND="${RDEPEND}
	dev-lang/swig"
