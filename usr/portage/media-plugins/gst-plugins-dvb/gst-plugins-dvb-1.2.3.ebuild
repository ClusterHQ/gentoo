# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-dvb/gst-plugins-dvb-1.2.3.ebuild,v 1.7 2014/04/21 10:29:42 ago Exp $

EAPI="5"

inherit gst-plugins10 gst-plugins-bad

DESCRIPION="GStreamer plugin to allow capture from dvb devices"
KEYWORDS="alpha amd64 arm ppc ppc64 x86"
IUSE=""

RDEPEND=""
DEPEND="virtual/os-headers"

src_compile() {
	# Prepare generated headers
	cd "${S}"/gst-libs/gst/mpegts
	emake

	cd "${S}"
	gst-plugins10_src_compile
}
