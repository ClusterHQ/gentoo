# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/distcc/distcc-3.1-r6.ebuild,v 1.3 2012/09/15 22:03:36 vapier Exp $

EAPI="3"
PYTHON_DEPEND="2"

inherit eutils fdo-mime flag-o-matic multilib python toolchain-funcs user prefix

DESCRIPTION="a program to distribute compilation of C code across several machines on a network"
HOMEPAGE="http://distcc.org/"
SRC_URI="http://distcc.googlecode.com/files/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~sparc64-solaris"
IUSE="avahi gnome gtk hardened ipv6 selinux xinetd"

RESTRICT="test"

RDEPEND="dev-libs/popt
	avahi? ( >=net-dns/avahi-0.6[dbus] )
	gnome? (
		>=gnome-base/libgnome-2
		>=gnome-base/libgnomeui-2
		x11-libs/gtk+:2
		x11-libs/pango
	)
	gtk? (
		x11-libs/gtk+:2
	)"
DEPEND="${RDEPEND}
	virtual/pkgconfig"
RDEPEND="${RDEPEND}
	!net-misc/pump
	>=sys-devel/gcc-config-1.4.1
	selinux? ( sec-policy/selinux-distcc )
	xinetd? ( sys-apps/xinetd )"

DISTCC_LOG=""
DCCC_PATH="/usr/$(get_libdir)/distcc/bin"
DISTCC_VERBOSE="0"

pkg_setup() {
	enewuser distcc 240 -1 -1 daemon
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-3.0-xinetd.patch"
	# bug #253786
	epatch "${FILESDIR}/${PN}-3.0-fix-fortify.patch"
	# bug #255188
	epatch "${FILESDIR}/${P}-freedesktop.patch"
	# bug #258364
	epatch "${FILESDIR}/${P}-python.patch"
	# bug #351979
	epatch "${FILESDIR}/${P}-argc-fix.patch"
	# fix runtime crashes of the python module (pump)
	epatch "${FILESDIR}/${P}-python-propagate-libs.patch"

	sed -i -e "/PATH/s:\$distcc_location:${EPREFIX}${DCCC_PATH}:" pump.in || die

	# Bugs #120001, #167844 and probably more. See patch for description.
	use hardened && epatch "${FILESDIR}/distcc-hardened.patch"

	# prefix awareness
	cp "${FILESDIR}"/distcc-config .
	epatch "${FILESDIR}"/distcc-config-prefix.patch
	eprefixify distcc-config
}

src_configure() {
	local myconf="--disable-Werror --with-docdir=${EPREFIX}/usr/share/doc/${PF}"
	# More legacy stuff?
	[ "$(gcc-major-version)" = "2" ] && filter-lfs-flags

	# --disable-rfc2553 b0rked, bug #254176
	use ipv6 && myconf="${myconf} --enable-rfc2553"

	econf \
		$(use_with avahi) \
		$(use_with gtk) \
		$(use_with gnome) \
		${myconf} || die "econf failed"
}

src_install() {
	# In rare cases, parallel make install failed
	emake -j1 DESTDIR="${D}" install || die

	#dobin "${FILESDIR}/3.0/distcc-config"
	dobin "${S}/distcc-config"

	newinitd "${FILESDIR}/${PV}/init" distccd

	cp "${FILESDIR}/3.0/conf" "${T}/distccd"
	if use avahi; then
		cat >> "${T}/distccd" <<-EOF

		# Enable zeroconf support in distccd
		DISTCCD_OPTS="\${DISTCCD_OPTS} --zeroconf"
		EOF
	fi
	doconfd "${T}/distccd"

	cat > "${T}/02distcc" <<-EOF
	# This file is managed by distcc-config; use it to change these settings.
	DISTCC_LOG="${DISTCC_LOG}"
	DCCC_PATH="${EPREFIX}${DCCC_PATH}"
	DISTCC_VERBOSE="${DISTCC_VERBOSE}"
	EOF
	doenvd "${T}/02distcc"

	# create the masquerade directory
	dodir "${DCCC_PATH}"
	for f in cc c++ gcc g++; do
		dosym /usr/bin/distcc "${DCCC_PATH}/${f}"
		if [ "${f}" != "cc" ]; then
			dosym /usr/bin/distcc "${DCCC_PATH}/${CTARGET:-${CHOST}}-${f}"
		fi
	done

	# create the distccd pid directory
	keepdir /var/run/distccd
	fowners distcc:daemon /var/run/distccd

	if use gnome || use gtk; then
		einfo "Renaming /usr/bin/distccmon-gnome to /usr/bin/distccmon-gui"
		einfo "This is to have a little sensability in naming schemes between distccmon programs"
		mv "${ED}/usr/bin/distccmon-gnome" "${ED}/usr/bin/distccmon-gui" || die
		dosym distccmon-gui /usr/bin/distccmon-gnome
	fi

	if use xinetd; then
		insinto /etc/xinetd.d
		newins "doc/example/xinetd" distcc
	fi

	rm -rf "${ED}/etc/default"
	rm -f "${ED}/etc/distcc/clients.allow"
	rm -f "${ED}/etc/distcc/commands.allow.sh"

	python_convert_shebangs -r $(python_get_version) "${ED}"
	sed -e "s:${EPREFIX}/usr/bin/python:$(PYTHON -a):" -i "${ED}usr/bin/pump" || die "sed failed"
}

pkg_postinst() {
	python_mod_optimize include_server
	use gnome && fdo-mime_desktop_database_update

	if use ipv6; then
		elog
		elog "IPv6 has not supported yet by ${P}."
	fi
	elog
	elog "Tips on using distcc with Gentoo can be found at"
	elog "http://www.gentoo.org/doc/en/distcc.xml"
	elog
	elog "How to use pump mode with Gentoo:"
	elog "# distcc-config --set-hosts \"foo,cpp,lzo bar,cpp,lzo baz,cpp,lzo\""
	elog "# pump emerge -u world"
	elog
	elog "To use the distccmon programs with Gentoo you should use this command:"
	elog "# DISTCC_DIR=\"${DISTCC_DIR}\" distccmon-text 5"

	if use gnome || use gtk; then
		elog "Or:"
		elog "# DISTCC_DIR=\"${DISTCC_DIR}\" distccmon-gnome"
	fi

	elog
	elog "***SECURITY NOTICE***"
	elog "If you are upgrading distcc please make sure to run etc-update to"
	elog "update your /etc/conf.d/distccd and /etc/init.d/distccd files with"
	elog "added security precautions (the --listen and --allow directives)"
	elog
}

pkg_postrm() {
	python_mod_cleanup include_server
	use gnome && fdo-mime_desktop_database_update
}
