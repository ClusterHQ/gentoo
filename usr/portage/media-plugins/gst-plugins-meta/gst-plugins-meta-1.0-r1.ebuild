# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-meta/gst-plugins-meta-1.0-r1.ebuild,v 1.18 2013/03/03 12:52:27 ago Exp $

EAPI="5"

DESCRIPTION="Meta ebuild to pull in gst plugins for apps"
HOMEPAGE="http://www.gentoo.org"

LICENSE="metapackage"
SLOT="1.0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~x64-macos ~x86-solaris"
IUSE="aac a52 alsa cdda dts dv dvb dvd ffmpeg flac http jack lame libass libvisual mms mp3 mpeg ogg opus oss pulseaudio taglib theora v4l vcd vorbis vpx wavpack X x264"
REQUIRED_USE="opus? ( ogg ) theora? ( ogg ) vorbis? ( ogg )"

RDEPEND="media-libs/gstreamer:1.0
	media-libs/gst-plugins-base:1.0[alsa?,ogg?,theora?,vorbis?,X?]
	media-libs/gst-plugins-good:1.0
	a52? ( media-plugins/gst-plugins-a52dec:1.0 )
	aac? ( media-plugins/gst-plugins-faad:1.0 )
	cdda? ( || (
		media-plugins/gst-plugins-cdparanoia:1.0
		media-plugins/gst-plugins-cdio:1.0 ) )
	dts? ( media-plugins/gst-plugins-dts:1.0 )
	dv? ( media-plugins/gst-plugins-dv:1.0 )
	dvb? (
		media-plugins/gst-plugins-dvb:1.0
		media-libs/gst-plugins-bad:1.0 )
	dvd? (
		media-libs/gst-plugins-ugly:1.0
		media-plugins/gst-plugins-a52dec:1.0
		media-plugins/gst-plugins-dvdread:1.0
		media-plugins/gst-plugins-mpeg2dec:1.0
		media-plugins/gst-plugins-resindvd:1.0 )
	ffmpeg? ( media-plugins/gst-plugins-libav:1.0 )
	flac? ( media-plugins/gst-plugins-flac:1.0 )
	http? ( media-plugins/gst-plugins-soup:1.0 )
	jack? ( media-plugins/gst-plugins-jack:1.0 )
	lame? ( media-plugins/gst-plugins-lame:1.0 )
	libass? ( media-plugins/gst-plugins-assrender:1.0 )
	libvisual? ( media-plugins/gst-plugins-libvisual:1.0 )
	mms? ( media-plugins/gst-plugins-libmms:1.0 )
	mp3? (
		media-libs/gst-plugins-ugly:1.0
		media-plugins/gst-plugins-mad:1.0 )
	mpeg? ( media-plugins/gst-plugins-mpeg2dec:1.0 )
	opus? ( media-plugins/gst-plugins-opus:1.0 )
	oss? ( media-plugins/gst-plugins-oss:1.0 )
	pulseaudio? ( media-plugins/gst-plugins-pulse:1.0 )
	taglib? ( media-plugins/gst-plugins-taglib:1.0 )
	v4l? ( media-plugins/gst-plugins-v4l2:1.0 )
	vcd? (
		media-plugins/gst-plugins-mplex:1.0
		media-plugins/gst-plugins-mpeg2dec:1.0 )
	vpx? ( media-plugins/gst-plugins-vpx:1.0 )
	wavpack? ( media-plugins/gst-plugins-wavpack:1.0 )
	x264? ( media-plugins/gst-plugins-x264:1.0 )"

# Usage note:
# The idea is that apps depend on this for optional gstreamer plugins.  Then,
# when USE flags change, no app gets rebuilt, and all apps that can make use of
# the new plugin automatically do.

# When adding deps here, make sure the keywords on the gst-plugin are valid.
