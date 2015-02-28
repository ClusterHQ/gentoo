# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/java-config/java-config-2.2.0.ebuild,v 1.8 2014/03/10 17:35:03 johu Exp $

EAPI="5"

# jython depends on java-config, so don't add it or things will break
PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3} )

inherit distutils-r1

DESCRIPTION="Java environment configuration query tool"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI="http://dev.gentoo.org/~sera/distfiles/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
# this needs testing/checking/updating
#KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

# baselayout-java is added as a dep till it can be added to eclass.
RDEPEND="
	>=dev-java/java-config-wrapper-0.15
	sys-apps/baselayout-java
	sys-apps/portage"

python_prepare() {
	epatch "${FILESDIR}/${P}-prefix.patch"
}

python_test() {
	esetup.py test || die
}
