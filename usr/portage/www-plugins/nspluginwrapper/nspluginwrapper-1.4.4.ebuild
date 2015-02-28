# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-plugins/nspluginwrapper/nspluginwrapper-1.4.4.ebuild,v 1.5 2012/05/03 06:08:02 jdhore Exp $

EAPI=2

inherit eutils multilib nsplugins flag-o-matic

DESCRIPTION="Netscape Plugin Wrapper - Load 32bit plugins on 64bit browser"
HOMEPAGE="http://nspluginwrapper.org/"
SRC_URI="http://web.mit.edu/davidben/Public/nspluginwrapper/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2:2
	net-misc/curl
	app-emulation/emul-linux-x86-xlibs
	app-emulation/emul-linux-x86-gtklibs
	>=sys-apps/util-linux-2.13"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

autoinstall() {
	if [[ -x /usr/bin/${PN} ]]; then
		einfo "Auto installing 32bit plugins..."
		${PN} -a -i
		ls /usr/$(get_libdir)/nsbrowser/plugins

		# Remove wrappers if equivalent 64-bit plugins exist
		# TODO: May be better to patch nspluginwrapper so it doesn't create
		#       duplicate wrappers in the first place...
		local DIR64="${ROOT}/usr/$(get_libdir)/nsbrowser/plugins/"
		for f in "${DIR64}"/npwrapper.*.so; do
			local PLUGIN=${f##*/npwrapper.}
			if [[ -f ${DIR64}/${PLUGIN} ]]; then
				einfo "  Removing duplicate wrapper for native 64-bit ${PLUGIN}"
				${PN} -r "${f}"
			fi
		done
	fi
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-1.3.0-gdk-native-windows.patch"
	epatch "${FILESDIR}/${P}-parallel-make.patch"
	epatch "${FILESDIR}/${P}-compile-on-hardened.patch"
}

src_configure() {
	replace-flags -O3 -O2

	./configure --enable-biarch \
		--target-cpu=i386 \
		--with-lib32=$(ABI=x86 get_libdir) \
		--with-lib64=$(get_libdir) \
		--pkglibdir=/usr/$(get_libdir)/${PN}
}

src_compile() {
	emake LDFLAGS_32="-m32 ${LDFLAGS}" || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dosym "/usr/$(get_libdir)/${PN}/x86_64/linux/npconfig" "/usr/bin/${PN}"
	keepdir "/usr/$(get_libdir)/${PLUGINS_DIR}"

	dodoc NEWS README TODO
}

pkg_postinst() {
	autoinstall
	elog "Any 32bit plugins you currently have installed have now been"
	elog "configured to work in a 64bit browser. Any plugins you install in"
	elog "the future will first need to be setup with:"
	elog "  \"nspluginwrapper -i <path-to-32bit-plugin>\""
	elog "before they will function in a 64bit browser"
	elog
}

# this is terribly ugly, but without a way to query portage as to whether
# we are upgrading/reinstalling a package versus unmerging, I can't think of
# a better way

pkg_prerm() {
	einfo "Removing wrapper plugins..."
	${PN} --auto --remove
}

pkg_postrm() {
	autoinstall
}
