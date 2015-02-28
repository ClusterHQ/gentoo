# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-opengl/eselect-opengl-1.2.4.ebuild,v 1.7 2011/10/03 17:45:54 josejx Exp $

EAPI=4

inherit multilib

DESCRIPTION="Utility to change the OpenGL interface being used"
HOMEPAGE="http://www.gentoo.org/"

# Source:
# http://www.opengl.org/registry/api/glext.h
# http://www.opengl.org/registry/api/glxext.h
GLEXT="67"
GLXEXT="32"

MIRROR="http://dev.gentooexperimental.org/~scarabeus/"
SRC_URI="${MIRROR}/glext.h.${GLEXT}.xz
	${MIRROR}/glxext.h.${GLXEXT}.xz
	mirror://gentoo/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="app-arch/xz-utils"
RDEPEND=">=app-admin/eselect-1.2.4"

pkg_postinst() {
	local impl="$(eselect opengl show)"
	if [[ -n "${impl}"  && "${impl}" != '(none)' ]] ; then
		eselect opengl set "${impl}"
	fi
}

src_install() {
	insinto "/usr/share/eselect/modules"
	doins opengl.eselect
	doman opengl.eselect.5

	# Install global glext.h and glxext.h
	insinto "/usr/$(get_libdir)/opengl/global/include"
	cd "${WORKDIR}"
	newins glext.h.${GLEXT} glext.h
	newins glxext.h.${GLXEXT} glxext.h
}
