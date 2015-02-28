# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/libdbi-drivers/libdbi-drivers-0.8.3-r2.ebuild,v 1.5 2014/08/10 20:00:44 slyfox Exp $

EAPI=4

inherit eutils autotools

MY_P="${P}-1"

DESCRIPTION="The libdbi-drivers project maintains drivers for libdbi"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"
HOMEPAGE="http://libdbi-drivers.sourceforge.net/"
LICENSE="LGPL-2.1"

IUSE="bindist doc firebird mysql oci8 postgres +sqlite static-libs"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
SLOT=0

RDEPEND="
	>=dev-db/libdbi-0.8.3
	firebird? ( dev-db/firebird )
	mysql? ( virtual/mysql )
	postgres? ( dev-db/postgresql-base )
	sqlite? ( dev-db/sqlite:3 )
"
DEPEND="${RDEPEND}
	doc? ( app-text/openjade )
"

S="${WORKDIR}/${MY_P}"

REQUIRED_USE="
	firebird? ( !bindist )
	|| ( mysql postgres sqlite firebird oci8 )
"

DOCS="AUTHORS ChangeLog NEWS README README.osx TODO"

pkg_setup() {
	use oci8 && [[ -z "${ORACLE_HOME}" ]] && die "\$ORACLE_HOME is not set!"
}

src_prepare() {
	epatch \
		"${FILESDIR}"/${P}-fix-ac-macro.patch \
		"${FILESDIR}"/${PN}-0.8.3-doc-build-fix.patch \
		"${FILESDIR}"/${PN}-0.8.3-oracle-build-fix.patch \
		"${FILESDIR}"/${PN}-0.8.3-firebird-fix.patch
	eautoreconf
}

src_configure() {
	local myconf=""
	# WARNING: the configure script does NOT work correctly
	# --without-$driver does NOT work
	# so do NOT use `use_with...`
	use mysql && myconf+=" --with-mysql"
	use postgres && myconf+=" --with-pgsql"
	use sqlite && myconf+=" --with-sqlite3"
	use firebird && myconf+=" --with-firebird"
	if use oci8; then
		[[ -z "${ORACLE_HOME}" ]] && die "\$ORACLE_HOME is not set!"
		myconf+=" --with-oracle-dir=${ORACLE_HOME} --with-oracle"
	fi

	econf \
		$(use_enable doc docs) \
		$(use_enable static-libs static) \
		${myconf}
}

src_test() {
	if [[ -z "${WANT_INTERACTIVE_TESTS}" ]]; then
		ewarn "Tests disabled due to interactivity."
		ewarn "Run with WANT_INTERACTIVE_TESTS=1 if you want them."
		return 0
	fi
	einfo "Running interactive tests"
	emake check
}

src_install() {
	default

	prune_libtool_files --all
}
