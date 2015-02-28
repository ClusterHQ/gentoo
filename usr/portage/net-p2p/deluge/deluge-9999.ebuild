# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/deluge/deluge-9999.ebuild,v 1.35 2014/08/10 20:36:34 slyfox Exp $

EAPI="3"
PYTHON_DEPEND="2:2.5"

inherit distutils git-2

EGIT_REPO_URI="git://deluge-torrent.org/${PN}.git
	http://git.deluge-torrent.org/${PN}/"

DESCRIPTION="BitTorrent client with a client/server model"
HOMEPAGE="http://deluge-torrent.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="geoip gtk libnotify setproctitle webinterface"

DEPEND=">=net-libs/rb_libtorrent-0.14.9[python]
	dev-python/setuptools"
RDEPEND="${DEPEND}
	dev-python/chardet
	dev-python/pyopenssl
	dev-python/pyxdg
	|| ( dev-lang/python:2.7 dev-lang/python:2.6 dev-python/simplejson )
	>=dev-python/twisted-core-8.1
	>=dev-python/twisted-web-8.1
	geoip? ( dev-libs/geoip )
	gtk? (
		dev-python/pygame
		dev-python/pygobject:2
		>=dev-python/pygtk-2.12
		gnome-base/librsvg
		libnotify? ( dev-python/notify-python )
	)
	setproctitle? ( dev-python/setproctitle )
	webinterface? ( dev-python/mako )"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	distutils_src_prepare
	python_convert_shebangs -r 2 .
	epatch "${FILESDIR}/${PN}-1.3.5-disable_libtorrent_internal_copy.patch"
}

src_install() {
	distutils_src_install
	newinitd "${FILESDIR}"/deluged.init deluged
	newconfd "${FILESDIR}"/deluged.conf deluged
}

pkg_postinst() {
	distutils_pkg_postinst
	elog
	elog "If after upgrading it doesn't work, please remove the"
	elog "'~/.config/deluge' directory and try again, but make a backup"
	elog "first!"
	elog
	elog "To start the daemon either run 'deluged' as user"
	elog "or modify /etc/conf.d/deluged and run"
	elog "/etc/init.d/deluged start as root"
	elog "You can still use deluge the old way"
	elog
	elog "For more information look at http://dev.deluge-torrent.org/wiki/Faq"
	elog
}
