# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-xvid/gst-plugins-xvid-0.10.23-r1.ebuild,v 1.10 2014/09/15 08:23:09 ago Exp $

EAPI="5"

GST_ORG_MODULE=gst-plugins-bad
inherit gstreamer

DESCRIPTION="GStreamer plugin for XviD (MPEG-4) video encoding/decoding support"
KEYWORDS="alpha amd64 ~arm hppa ia64 ppc ppc64 sparc x86 ~amd64-fbsd"
IUSE=""

RDEPEND=">=media-libs/xvid-1.3.2-r1[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
