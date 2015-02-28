# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/gpa/gpa-0.9.3.ebuild,v 1.7 2013/01/12 22:16:07 alonbl Exp $

EAPI=4

DESCRIPTION="The GNU Privacy Assistant (GPA) is a graphical user interface for GnuPG"
HOMEPAGE="http://gpa.wald.intevation.org"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="alpha amd64 ppc ppc64 sparc x86"
IUSE_LINGUAS=" ar cs de es fr ja nl pl pt_BR ru sv tr zh_TW"
IUSE="nls ${IUSE_LINGUAS// / linguas_}"

RDEPEND=">=x11-libs/gtk+-2.10.0:2
	>=dev-libs/libgpg-error-1.4
	>=dev-libs/libassuan-1.1.0
	>=app-crypt/gnupg-2
	>=app-crypt/gpgme-1.2.0"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	nls? ( sys-devel/gettext )"

src_prepare() {
	sed -i 's/Application;//' gpa.desktop
}

src_configure() {
	econf \
		--with-gpgme-prefix=/usr \
		--with-libassuan-prefix=/usr \
		$(use_enable nls) \
		GPGKEYS_LDAP="/usr/libexec/gpgkeys_ldap"
}

DOCS=( AUTHORS ChangeLog README NEWS TODO )
