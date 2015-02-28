# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-shout2/gst-plugins-shout2-0.10.31.ebuild,v 1.8 2013/02/24 18:00:48 ago Exp $

EAPI="5"

inherit gst-plugins-good

DESCRIPTION="GStreamer plugin to send data to an icecast server"
KEYWORDS="alpha amd64 ppc ppc64 sh x86"
IUSE=""

RDEPEND=">=media-libs/libshout-2"
DEPEND="${RDEPEND}"
