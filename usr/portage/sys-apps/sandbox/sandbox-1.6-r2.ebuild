# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/sandbox/sandbox-1.6-r2.ebuild,v 1.17 2012/03/30 15:58:53 aballier Exp $

#
# don't monkey with this ebuild unless contacting portage devs.
# period.
#

inherit eutils flag-o-matic toolchain-funcs multilib unpacker

DESCRIPTION="sandbox'd LD_PRELOAD hack"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.lzma
	http://dev.gentoo.org/~vapier/dist/${P}.tar.lzma"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE=""

DEPEND="app-arch/xz-utils
	>=app-misc/pax-utils-0.1.19" #265376
RDEPEND=""

EMULTILIB_PKG="true"
has sandbox_death_notice ${EBUILD_DEATH_HOOKS} || EBUILD_DEATH_HOOKS="${EBUILD_DEATH_HOOKS} sandbox_death_notice"

sandbox_death_notice() {
	ewarn "If configure failed with a 'cannot run C compiled programs' error, try this:"
	ewarn "FEATURES=-sandbox emerge sandbox"
}

src_unpack() {
	unpacker_src_unpack
	cd "${S}"
	epatch "${FILESDIR}"/${P}-disable-qa-static.patch
	epatch "${FILESDIR}"/${P}-disable-pthread.patch
	epatch "${FILESDIR}"/0001-libsandbox-handle-more-at-functions.patch
}

src_compile() {
	filter-lfs-flags #90228

	local OABI=${ABI}
	for ABI in $(get_install_abis) ; do
		mkdir "${WORKDIR}/build-${ABI}"
		cd "${WORKDIR}/build-${ABI}"

		multilib_toolchain_setup ${ABI}

		einfo "Configuring sandbox for ABI=${ABI}..."
		ECONF_SOURCE="../${P}/" \
		econf ${myconf} || die
		einfo "Building sandbox for ABI=${ABI}..."
		emake || die
	done
	ABI=${OABI}
}

src_test() {
	local OABI=${ABI}
	for ABI in $(get_install_abis) ; do
		cd "${WORKDIR}/build-${ABI}"
		einfo "Checking sandbox for ABI=${ABI}..."
		emake check || die "make check failed for ${ABI}"
	done
	ABI=${OABI}
}

src_install() {
	local OABI=${ABI}
	for ABI in $(get_install_abis) ; do
		cd "${WORKDIR}/build-${ABI}"
		einfo "Installing sandbox for ABI=${ABI}..."
		emake DESTDIR="${D}" install || die "make install failed for ${ABI}"
	done
	ABI=${OABI}

	doenvd "${FILESDIR}"/09sandbox

	keepdir /var/log/sandbox
	use prefix || fowners root:portage /var/log/sandbox
	fperms 0770 /var/log/sandbox

	cd "${S}"
	dodoc AUTHORS ChangeLog* NEWS README
}

pkg_preinst() {
	use prefix || chown root:portage "${ED}"/var/log/sandbox
	chmod 0770 "${ED}"/var/log/sandbox

	local old=$(find "${EROOT}"/lib* -maxdepth 1 -name 'libsandbox*')
	if [[ -n ${old} ]] ; then
		elog "Removing old sandbox libraries for you:"
		elog ${old//${EROOT}}
		find "${EROOT}"/lib* -maxdepth 1 -name 'libsandbox*' -exec rm -fv {} \;
	fi
}

pkg_postinst() {
	chmod 0755 "${EROOT}"/etc/sandbox.d #265376
}
