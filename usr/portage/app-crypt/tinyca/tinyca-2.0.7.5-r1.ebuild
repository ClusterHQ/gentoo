# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/tinyca/tinyca-2.0.7.5-r1.ebuild,v 1.4 2013/07/04 12:18:41 ago Exp $

inherit eutils

MY_P="${PN}${PV/./-}"
DESCRIPTION="Simple Perl/Tk GUI to manage a small certification authority"
HOMEPAGE="http://tinyca.sm-zone.net/"
SRC_URI="http://tinyca.sm-zone.net/${MY_P}.tar.bz2"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="amd64 ~ppc ~sparc x86"
IUSE=""
LANGS="en de cs es sv"

for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

RDEPEND=">=dev-libs/openssl-0.9.7e
	dev-perl/Locale-gettext
	>=virtual/perl-MIME-Base64-2.12
	>=dev-perl/gtk2-perl-1.072"
DEPEND="${RDEPEND}
	>=sys-apps/sed-4"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-2.0.7.3-compositefix.patch"
	epatch "${FILESDIR}/${P}-openssl-1.patch"
	sed -i -e 's:./lib:/usr/share/tinyca/lib:g' \
		-e 's:./templates:/usr/share/tinyca/templates:g' \
		-e 's:./locale:/usr/share/locale:g' "${S}/tinyca2"
}

src_compile() {
	emake -C po || die
}

locale_install() {
	dodir /usr/share/locale/$@/LC_MESSAGES/
	insinto /usr/share/locale/$@/LC_MESSAGES/
	doins locale/$@/LC_MESSAGES/tinyca2.mo
}

src_install() {
	exeinto /usr/bin
	newexe tinyca2 tinyca
	insinto /usr/share/tinyca/lib
	doins lib/*.pm
	insinto /usr/share/tinyca/lib/GUI
	doins lib/GUI/*.pm
	insinto /usr/share/tinyca/templates
	doins templates/*
	insinto /usr/share/
	strip-linguas ${LANGS}
	local l
	for l in ${LANGS}; do
		if [ "$l" != "en" ]; then
			use linguas_$l && locale_install $l
		fi
	done
}
