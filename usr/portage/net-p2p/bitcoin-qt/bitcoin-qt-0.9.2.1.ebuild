# Copyright 2010-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/bitcoin-qt/bitcoin-qt-0.9.2.1.ebuild,v 1.6 2014/08/29 00:52:25 blueness Exp $

EAPI=4

DB_VER="4.8"

LANGS="ach af_ZA ar be_BY bg bs ca ca@valencia ca_ES cmn cs cy da de el_GR en eo es es_CL es_DO es_MX es_UY et eu_ES fa fa_IR fi fr fr_CA gl gu_IN he hi_IN hr hu id_ID it ja ka kk_KZ ko_KR ky la lt lv_LV mn ms_MY nb nl pam pl pt_BR pt_PT ro_RO ru sah sk sl_SI sq sr sv th_TH tr uk ur_PK uz@Cyrl vi vi_VN zh_HK zh_CN zh_TW"
inherit autotools db-use eutils fdo-mime gnome2-utils kde4-functions qt4-r2 user versionator

MyPV="${PV/_/}"
MyPN="bitcoin"
MyP="${MyPN}-${MyPV}"

DESCRIPTION="An end-user Qt4 GUI for the Bitcoin crypto-currency"
HOMEPAGE="http://bitcoin.org/"
SRC_URI="https://github.com/${MyPN}/${MyPN}/archive/v${MyPV}.tar.gz -> ${MyPN}-v${PV}.tgz
"

LICENSE="MIT ISC GPL-3 LGPL-2.1 public-domain || ( CC-BY-SA-3.0 LGPL-2.1 )"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="$IUSE dbus kde +qrcode test upnp"

RDEPEND="
	>=dev-libs/boost-1.53.0[threads(+)]
	dev-libs/openssl:0[-bindist]
	dev-libs/protobuf
	qrcode? (
		media-gfx/qrencode
	)
	upnp? (
		net-libs/miniupnpc
	)
	sys-libs/db:$(db_ver_to_slot "${DB_VER}")[cxx]
	virtual/bitcoin-leveldb
	dev-qt/qtgui:4
	dbus? (
		dev-qt/qtdbus:4
	)
"
DEPEND="${RDEPEND}
	>=app-shells/bash-4.1
"

S="${WORKDIR}/${MyP}"

src_prepare() {
	epatch "${FILESDIR}/0.9.0-sys_leveldb.patch"
	rm -r src/leveldb

	local filt= yeslang= nolang=

	for lan in $LANGS; do
		if [ ! -e src/qt/locale/bitcoin_$lan.ts ]; then
			ewarn "Language '$lan' no longer supported. Ebuild needs update."
		fi
	done

	for ts in $(ls src/qt/locale/*.ts)
	do
		x="${ts/*bitcoin_/}"
		x="${x/.ts/}"
		if ! use "linguas_$x"; then
			nolang="$nolang $x"
			rm "$ts"
			filt="$filt\\|$x"
		else
			yeslang="$yeslang $x"
		fi
	done
	filt="bitcoin_\\(${filt:2}\\)\\.\(qm\|ts\)"
	sed "/${filt}/d" -i 'src/qt/bitcoin.qrc'
	sed "s/locale\/${filt}/bitcoin.qrc/" -i 'src/qt/Makefile.am'
	einfo "Languages -- Enabled:$yeslang -- Disabled:$nolang"

	eautoreconf
}

src_configure() {
	econf \
		$(use_with dbus qtdbus)  \
		$(use_with upnp miniupnpc) $(use_enable upnp upnp-default) \
		$(use_with qrcode qrencode)  \
		$(use_enable test tests)  \
		--with-system-leveldb  \
		--without-cli --without-daemon \
		--with-gui
}

src_test() {
	emake check
}

src_install() {
	emake DESTDIR="${D}" install

	insinto /usr/share/pixmaps
	newins "share/pixmaps/bitcoin.ico" "${PN}.ico"
	make_desktop_entry "${PN} %u" "Bitcoin-Qt" "/usr/share/pixmaps/${PN}.ico" "Qt;Network;P2P;Office;Finance;" "MimeType=x-scheme-handler/bitcoin;\nTerminal=false"

	dodoc doc/README.md doc/release-notes.md
	dodoc doc/assets-attribution.md doc/tor.md
	doman contrib/debian/manpages/bitcoin-qt.1

	if use kde; then
		insinto /usr/share/kde4/services
		doins contrib/debian/bitcoin-qt.protocol
	fi
}

update_caches() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
	buildsycoca
}

pkg_postinst() {
	update_caches
}

pkg_postrm() {
	update_caches
}
