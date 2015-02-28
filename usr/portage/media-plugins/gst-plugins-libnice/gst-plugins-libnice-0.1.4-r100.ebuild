# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-libnice/gst-plugins-libnice-0.1.4-r100.ebuild,v 1.10 2013/10/22 07:21:09 ago Exp $

EAPI=5
inherit eutils toolchain-funcs

DESCRIPTION="GStreamer plugin for ICE (RFC 5245) support"
HOMEPAGE="http://nice.freedesktop.org/wiki/"
MY_P=libnice-${PV}
SRC_URI="http://nice.freedesktop.org/releases/${MY_P}.tar.gz"

LICENSE="|| ( MPL-1.1 LGPL-2.1 )"
SLOT="1.0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

# ${PN} was part of net-libs/libnice before 0.1.3-r1
RDEPEND="~net-libs/libnice-${PV}
	media-libs/gstreamer:1.0
	media-libs/gst-plugins-base:1.0
	>net-libs/libnice-0.1.3
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

S="${WORKDIR}/${MY_P}/gst"

src_prepare() {
	local pkgconfig=$(tc-getPKG_CONFIG)
	local libs=$("${pkgconfig}" --libs-only-l nice)
	sed -e 's:$(top_builddir)/nice/libnice.la:'"${libs}:" \
		-i Makefile.{am,in} || die "sed failed"
}

src_configure() {
	cd "${WORKDIR}/${MY_P}" || die
	# gupnp is not used in the gst plugin
	econf \
		--disable-static \
		--without-gstreamer-0.10 \
		--with-gstreamer \
		--disable-gupnp
}

src_install() {
	default
	prune_libtool_files --modules
}
