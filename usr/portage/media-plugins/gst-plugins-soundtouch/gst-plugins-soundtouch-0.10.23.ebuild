# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-soundtouch/gst-plugins-soundtouch-0.10.23.ebuild,v 1.3 2013/02/01 12:37:54 ago Exp $

EAPI="5"

inherit gst-plugins-bad

DESCRIPTION="GStreamer elements for beats-per-minute detection and pitch controlling"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND=">=media-libs/libsoundtouch-1.4"
DEPEND="${RDEPEND}"
