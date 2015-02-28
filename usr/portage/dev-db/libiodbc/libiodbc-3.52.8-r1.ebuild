# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/libiodbc/libiodbc-3.52.8-r1.ebuild,v 1.2 2014/08/10 20:00:58 slyfox Exp $

EAPI="5"

inherit autotools eutils

MY_PN="iODBC"

DESCRIPTION="ODBC Interface for Linux"
HOMEPAGE="http://www.iodbc.org/"
SRC_URI="https://github.com/openlink/${MY_PN}/archive/v${PV}.zip -> ${P}.zip"

KEYWORDS="~amd64 ~x86"
LICENSE="|| ( LGPL-2 BSD )"
SLOT="0"
IUSE="gtk"

RDEPEND=">=sys-libs/readline-4.1
	>=sys-libs/ncurses-5.2
	gtk? ( x11-libs/gtk+:2 )"

DEPEND="${RDEPEND}"

DOCS="AUTHORS ChangeLog NEWS README"

S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	sed -i.orig \
		-e '/^cd "$PREFIX"/,/^esac/d' \
		iodbc/install_libodbc.sh || die "sed failed"
	epatch \
		"${FILESDIR}"/libiodbc-3.52.7-debian_bug501100.patch \
		"${FILESDIR}"/libiodbc-3.52.7-debian_bug508480.patch \
		"${FILESDIR}"/libiodbc-3.52.7-gtk.patch \
		"${FILESDIR}"/libiodbc-3.52.7-multilib.patch \
		"${FILESDIR}"/libiodbc-3.52.7-unicode_includes.patch \
		"${FILESDIR}"/libiodbc-3.52.8-gtk-parallel-make.patch \
		"${FILESDIR}"/libiodbc-3.52.8-runtime-failures.patch \
		"${FILESDIR}"/fix-runpaths.patch
	chmod -x include/*.h || die
	eautoreconf
}

src_configure() {
	econf \
		--disable-static \
		--enable-odbc3 \
		--enable-pthreads \
		--with-layout=gentoo \
		--with-iodbc-inidir=yes \
		$(use_enable gtk gui)
}

src_install() {
	default
	prune_libtool_files

	# Install lintian overrides
	insinto /usr/share/lintian/overrides
	newins debian/iodbc.lintian-overrides iodbc
	newins debian/libiodbc2.lintian-overrides libiodbc2

}
