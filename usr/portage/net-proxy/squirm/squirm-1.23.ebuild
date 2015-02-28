# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-proxy/squirm/squirm-1.23.ebuild,v 1.7 2008/10/12 08:05:06 mrness Exp $

DESCRIPTION="A redirector for Squid"
HOMEPAGE="http://squirm.foote.com.au"
SRC_URI="http://squirm.foote.com.au/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="ppc x86"
IUSE=""

src_unpack() {
	unpack ${A}

	sed -i \
		-e 's|^EXTRALIBS=.*|EXTRALIBS=|' \
		-e 's|^PREFIX=.*|PREFIX=/usr/squirm|' \
		-e "s|^OPTIMISATION=.*|OPTIMISATION=${CFLAGS}|" \
		-e "s|^CFLAGS =.*|CFLAGS=${CFLAGS} -DPREFIX=\\\\\"\$(PREFIX)\\\\\"|" \
		-e "s|--strip||" \
		"${S}/Makefile"
}

src_install() {
	make PREFIX="${D}/usr/squirm" install || die "make install failed"
}

pkg_postinst() {
	einfo "To enable squirm, add the following lines to /etc/squid/squid.conf:"
	einfo "    url_rewrite_program /usr/squirm/bin/squirm"
	einfo "    url_rewrite_children 10"
}
