# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/smplayer-skins/smplayer-skins-20121029.ebuild,v 1.1 2013/05/25 07:41:29 yngwin Exp $

EAPI=5

DESCRIPTION="Skins for SMPlayer"
HOMEPAGE="http://smplayer.sourceforge.net/"
SRC_URI="mirror://sourceforge/smplayer/${P}.tar.bz2"

LICENSE="CC-BY-2.5 CC-BY-SA-2.5 CC-BY-SA-3.0 GPL-2 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE=""

DEPEND=""
RDEPEND="media-video/smplayer"

# Override it as default will call make that will catch the install target...
src_compile() {
	:
}

src_install() {
	insinto /usr/share/smplayer
	doins -r themes
	dodoc Changelog README.txt
}
