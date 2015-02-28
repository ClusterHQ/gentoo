# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-soundtouch/gst-plugins-soundtouch-1.2.4.ebuild,v 1.1 2014/05/31 15:10:54 pacho Exp $

EAPI="5"

inherit gst-plugins-bad

DESCRIPTION="GStreamer elements for beats-per-minute detection and pitch controlling"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=media-libs/libsoundtouch-1.4"
DEPEND="${RDEPEND}"
