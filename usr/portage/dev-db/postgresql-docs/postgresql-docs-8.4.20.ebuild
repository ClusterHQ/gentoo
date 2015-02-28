# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/postgresql-docs/postgresql-docs-8.4.20.ebuild,v 1.10 2014/03/12 10:24:30 ago Exp $

EAPI="4"

inherit versionator

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 ~s390 ~sh sparc x86 ~sparc-fbsd ~x86-fbsd"

RESTRICT="test"

DESCRIPTION="PostgreSQL documentation"
HOMEPAGE="http://www.postgresql.org/"
SRC_URI="mirror://postgresql/source/v${PV}/postgresql-${PV}.tar.bz2"
LICENSE="POSTGRESQL"

S=${WORKDIR}/postgresql-${PV}
SLOT="$(get_version_component_range 1-2)"

IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	tar xjf "${DISTDIR}/${A}" -C "${WORKDIR}" "${A%.tar.bz2}/doc"
}

src_install() {
	# Don't use ${PF} here as three packages
	# (dev-db/postgresql-{docs,base,server}) have the same set of docs.
	local mypath=/usr/share/doc/postgresql-${SLOT}

	cd "${S}/doc"

	dodir ${mypath}/html
	tar -zxf "postgres.tar.gz" -C "${ED}${mypath}/html" || die

	insinto ${mypath}/sgml
	doins src/sgml/*.{sgml,dsl}

	insinto ${mypath}/sgml/ref
	doins src/sgml/ref/*.sgml

	fowners root:0 -R ${mypath}

	dodir /etc/eselect/postgresql/slots/${SLOT}
	echo "postgres_ebuilds=\"\${postgres_ebuilds} ${PF}\"" > \
		"${ED}/etc/eselect/postgresql/slots/${SLOT}/docs"
}
