# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-fps/postal2/postal2-1409.2-r1.ebuild,v 1.6 2012/02/05 06:04:07 vapier Exp $

EAPI=2
inherit eutils unpacker cdrom multilib games

DESCRIPTION="Postal 2: Share the Pain"
HOMEPAGE="http://www.linuxgamepublishing.com/info.php?id=postal2"
SRC_URI="http://updatefiles.linuxgamepublishing.com/${PN}/${P/%?/1}.run
	http://updatefiles.linuxgamepublishing.com/${PN}/${P}.run"

LICENSE="postal2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
RESTRICT="strip"

DEPEND="games-util/loki_patch"
RDEPEND="sys-libs/glibc
	virtual/opengl
	virtual/libstdc++:3.3
	amd64? ( app-emulation/emul-linux-x86-sdl )
	x86? (
		media-libs/libsdl[X,opengl]
		media-libs/openal
	)"

S=${WORKDIR}

src_unpack() {
	cdrom_get_cds .installation_data/linux-specific.tar.bz2
	mkdir ${A}

	local f
	for f in * ; do
		cd "${S}"/${f}
		unpack_makeself ${f}
	done
}

src_install() {
	has_multilib_profile && ABI=x86

	local dir=${GAMES_PREFIX_OPT}/${PN}

	dodir "${dir}"
	cd "${D}/${dir}"

	ln -s "${CDROM_ROOT}"/.installation_data/*.bz2 .
	unpack ./*.bz2
	rm -f ./*.bz2

	local d
	for d in "${S}"/* ; do
		pushd "${d}" > /dev/null
		loki_patch patch.dat "${D}/${dir}" || die "loki_patch ${d} failed"
		popd > /dev/null
	done

	rm -f System/{libstdc++.so.5,libgcc_s.so.1}

	dosym /usr/$(get_libdir)/libopenal.so "${dir}"/System/openal.so || die
	dosym /usr/$(get_libdir)/libSDL-1.2.so.0 "${dir}"/System/libSDL-1.2.so.0 \
		|| die

	games_make_wrapper ${PN} ./${PN}-bin "${dir}"/System .
	doicon "${CDROM_ROOT}"/.installation_data/${PN}.xpm
	make_desktop_entry ${PN} "Postal 2: Share the Pain"

	prepgamesdirs
}
