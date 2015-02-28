# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/putty/putty-0.63-r1.ebuild,v 1.7 2014/01/18 20:04:21 ago Exp $

EAPI=5

inherit autotools eutils gnome2-utils toolchain-funcs versionator

DESCRIPTION="A Free Telnet/SSH Client"
HOMEPAGE="http://www.chiark.greenend.org.uk/~sgtatham/putty/"
SRC_URI="
	http://the.earth.li/~sgtatham/${PN}/latest/${P}.tar.gz
	http://dev.gentoo.org/~jer/${PN}-icons.tar.bz2"
LICENSE="MIT"

SLOT="0"
KEYWORDS="alpha amd64 hppa ppc sparc x86"
IUSE="doc +gtk ipv6 kerberos"

RDEPEND="
	!net-misc/pssh
	kerberos? ( virtual/krb5 )
	gtk? ( x11-libs/gdk-pixbuf
		x11-libs/gtk+:2
		x11-libs/libX11
		x11-libs/pango
		dev-libs/glib )
"
DEPEND="
	${RDEPEND}
	dev-lang/perl
	virtual/pkgconfig
"

src_prepare() {
	cd "${S}"/unix || die
	sed -i \
		-e '/AM_PATH_GTK(/d' \
		-e 's|-Wall -Werror||g' \
		configure.ac || die

	eautoreconf
}

src_configure() {
	cd "${S}"/unix || die
	econf \
		$(use_with kerberos gssapi) \
		$(use_with gtk)
}

src_compile() {
	cd "${S}"/unix || die
	emake AR=$(tc-getAR) $(usex ipv6 '' COMPAT=-DNO_IPV6)
}

src_install() {
	dodoc doc/puttydoc.txt

	if use doc; then
		dohtml doc/*.html
	fi

	cd "${S}"/unix || die
	default

	if use gtk ; then
		for i in 16 22 24 32 48 64 128 256; do
			newicon -s ${i} "${WORKDIR}"/${PN}-icons/${PN}-${i}.png ${PN}.png
		done

		# install desktop file provided by Gustav Schaffter in #49577
		make_desktop_entry ${PN} PuTTY ${PN} Network
	fi
}

pkg_preinst() {
	use gtk && gnome2_icon_savelist
}

pkg_postinst() {
	use gtk && gnome2_icon_cache_update
}

pkg_postrm() {
	use gtk && gnome2_icon_cache_update
}
