# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/udev-init-scripts/udev-init-scripts-26-r2.ebuild,v 1.11 2014/07/22 12:45:52 vapier Exp $

EAPI=5

inherit eutils udev

if [ "${PV}" = "9999" ]; then
	EGIT_REPO_URI="git://git.overlays.gentoo.org/proj/udev-gentoo-scripts.git"
	inherit git-2
fi

DESCRIPTION="udev startup scripts for openrc"
HOMEPAGE="http://www.gentoo.org"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

if [ "${PV}" != "9999" ]; then
	SRC_URI="http://dev.gentoo.org/~williamh/dist/${P}.tar.bz2"
	KEYWORDS="alpha amd64 arm arm64 hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86"
fi

RESTRICT="test"

RDEPEND=">=virtual/udev-180
	!<sys-fs/udev-186"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	epatch_user
}

src_install() {
	default

	# These are now part of >=net-misc/netifrc-0.2.1:
	rm -f "${D}"/$(get_udevdir)/{net.sh,rules.d/90-network.rules}
}

pkg_postinst() {
	# Add udev and udev-mount to the sysinit runlevel automatically if this is
	# the first install of this package.
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		if [[ ! -d ${ROOT%/}/etc/runlevels/sysinit ]]; then
			mkdir -p "${ROOT%/}"/etc/runlevels/sysinit
		fi
		if [[ -x ${ROOT%/}/etc/init.d/udev ]]; then
			ln -s /etc/init.d/udev "${ROOT%/}"/etc/runlevels/sysinit/udev
		fi
		if [[ -x ${ROOT%/}/etc/init.d/udev-mount ]]; then
			ln -s /etc/init.d/udev-mount \
				"${ROOT%/}"/etc/runlevels/sysinit/udev-mount
		fi
	fi

	# Warn the user about adding the scripts to their sysinit runlevel
	if [[ -e ${ROOT%/}/etc/runlevels/sysinit ]]; then
		if [[ ! -e ${ROOT%/}/etc/runlevels/sysinit/udev ]]; then
			ewarn
			ewarn "You need to add udev to the sysinit runlevel."
			ewarn "If you do not do this,"
			ewarn "your system will not be able to boot!"
			ewarn "Run this command:"
			ewarn "\trc-update add udev sysinit"
		fi
		if [[ ! -e ${ROOT%/}/etc/runlevels/sysinit/udev-mount ]]; then
			ewarn
			ewarn "You need to add udev-mount to the sysinit runlevel."
			ewarn "If you do not do this,"
			ewarn "your system will not be able to boot!"
			ewarn "Run this command:"
			ewarn "\trc-update add udev-mount sysinit"
		fi
	fi

	if ! has_version "sys-fs/eudev[rule-generator]" && \
	[[ -x $(type -P rc-update) ]] && rc-update show | grep udev-postmount | grep -qs 'boot\|default\|sysinit'; then
		ewarn "The udev-postmount service has been removed because the reasons for"
		ewarn "its existance have been removed upstream."
		ewarn "Please remove it from your runlevels."
	fi
}
