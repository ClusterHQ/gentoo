# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/hydra/hydra-7.6.ebuild,v 1.1 2014/01/11 12:22:54 jer Exp $

EAPI=5
inherit eutils toolchain-funcs

DESCRIPTION="Advanced parallized login hacker"
HOMEPAGE="http://www.thc.org/thc-hydra/"
SRC_URI="http://freeworld.thc.org/releases/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="firebird gtk idn mysql ncp oracle pcre postgres ssl subversion"

RDEPEND="
	dev-libs/openssl
	sys-libs/ncurses
	firebird? ( dev-db/firebird )
	gtk? (
		dev-libs/atk
		dev-libs/glib:2
		x11-libs/gdk-pixbuf:2
		x11-libs/gtk+:2
	)
	idn? ( net-dns/libidn )
	mysql? ( virtual/mysql )
	ncp? ( net-fs/ncpfs )
	oracle? ( dev-db/oracle-instantclient-basic )
	pcre? ( dev-libs/libpcre )
	postgres? ( dev-db/postgresql-base )
	ssl? ( >=net-libs/libssh-0.4.0 )
	subversion? ( dev-vcs/subversion )
"
DEPEND="
	${RDEPEND}
	virtual/pkgconfig
"

src_prepare() {
	# None of the settings in Makefile.unix are useful to us
	: > Makefile.unix

	sed -i \
		-e 's:|| echo.*$::' \
		-e '/\t-$(CC)/s:-::' \
		-e '/^OPTS/{s|=|+=|;s| -O3||}' \
		-e '/ -o /s:$(OPTS):& $(LDFLAGS):g' \
		Makefile.am || die
}

src_configure() {
	export OPTS="${CFLAGS}"

	if ! use subversion; then
		sed -i 's/-lsvn_client-1 -lapr-1 -laprutil-1 -lsvn_subr-1//;s/-DLIBSVN//' configure || die
	fi

	if ! use mysql; then
		sed -i 's/-lmysqlclient//;s/-DLIBMYSQLCLIENT//' configure || die
	fi

	# Linking against libtinfo might be enough here but pkg-config --libs tinfo
	# would require a USE=tinfo flag and recent linkers should drop libcurses
	# as needed
	sed -i \
		-e 's|-lcurses|'"$( $(tc-getPKG_CONFIG) --libs ncurses)"'|g' \
		configure || die

	# Note: despite the naming convention, the top level script is not an
	# autoconf-based script.
	./configure \
		--prefix=/usr \
		--nostrip \
		$(use gtk && echo --disable-xhydra) \
			|| die

	if use gtk ; then
		cd hydra-gtk && \
		econf
	fi
}

src_compile() {
	tc-export CC
	emake
	use gtk && emake -C hydra-gtk
}

src_install() {
	dobin hydra pw-inspector
	use gtk && dobin hydra-gtk/src/xhydra
	dodoc CHANGES README
}
