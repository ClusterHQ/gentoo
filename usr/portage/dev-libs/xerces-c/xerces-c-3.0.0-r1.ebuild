# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/xerces-c/xerces-c-3.0.0-r1.ebuild,v 1.9 2008/12/14 12:43:46 maekke Exp $

inherit eutils

DESCRIPTION="A validating XML parser written in a portable subset of C++."
HOMEPAGE="http://xerces.apache.org/xerces-c/"
SRC_URI="mirror://apache/xerces/c/3/sources/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="curl debug doc iconv icu libwww threads elibc_Darwin elibc_FreeBSD"

RDEPEND="icu? ( dev-libs/icu )
	curl? ( net-misc/curl )
	libwww? ( net-libs/libwww )
	virtual/libiconv"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

pkg_setup() {
	export ICUROOT="${EPREFIX}/usr"

	if use iconv && use icu ; then
		ewarn "This package can use iconv or icu for loading messages"
		ewarn "and transcoding, but not both. ICU will precede."
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i \
		-e 's|$(prefix)/msg|$(DESTDIR)/$(prefix)/share/xerces-c/msg|' \
		src/xercesc/util/MsgLoaders/MsgCatalog/Makefile.in || die "sed failed"
	
	epatch "${FILESDIR}"/${P}-gcc4.2-darwin.patch
}

src_compile() {
	local mloader="inmemory"
	use iconv && mloader="iconv"
	use icu && mloader="icu"

	local transcoder="gnuiconv"
	use elibc_FreeBSD && transcoder="iconv"
	use elibc_Darwin && transcoder="macosunicodeconverter"
	use icu && transcoder="icu"

	# 'cfurl' is only available on OSX and 'socket' isn't supposed to work.
	# But the docs aren't clear about it, so we would need some testing...
	local netaccessor="socket"
	use elibc_Darwin && netaccessor="cfurl"
	use libwww && netaccessor="libwww"
	use curl && netaccessor="curl"

	econf \
		$(use_enable debug) \
		$(use_enable threads) \
		--enable-msgloader-${mloader} \
		--enable-netaccessor-${netaccessor} \
		--enable-transcoder-${transcoder} \
		|| die "econf failed"

	emake || die "emake failed"

	if use doc ; then
		cd "${S}/doc"
		doxygen || die "making docs failed"
	fi
}

src_install () {
	emake DESTDIR="${D}" install || die "emake failed"

	cd "${S}"
	cp "${FILESDIR}/50xerces-c" .
	sed -i -e '/XERCESC_NLS_HOME/s:=":="'"${EPREFIX}"':' 50xerces-c
	doenvd 50xerces-c

	if use doc; then
		insinto /usr/share/doc/${PF}
		rm -rf samples/config* samples/Makefile* samples/runConfigure \
		samples/install-sh samples/*/Makefile* samples/.libs
		rm samples/*
		doins -r samples
		dohtml -r doc/html/*
	fi

	dodoc CREDITS KEYS NOTICE README version.incl
}
