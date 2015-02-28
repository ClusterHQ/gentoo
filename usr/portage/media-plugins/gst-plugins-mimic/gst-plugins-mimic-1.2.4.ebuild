# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-mimic/gst-plugins-mimic-1.2.4.ebuild,v 1.1 2014/05/31 14:51:32 pacho Exp $

EAPI="5"

inherit gst-plugins-bad

DESCRIPTION="GStreamer plugin for the MIMIC codec"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=media-libs/libmimic-1.0.4"
DEPEND="${RDEPEND}"
