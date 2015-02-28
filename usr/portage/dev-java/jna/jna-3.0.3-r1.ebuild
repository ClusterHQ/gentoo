# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jna/jna-3.0.3-r1.ebuild,v 1.4 2012/05/03 07:42:50 jdhore Exp $

EAPI=2

JAVA_PKG_IUSE="test doc source"
WANT_ANT_TASKS="ant-nodeps"

inherit java-pkg-2 java-ant-2 toolchain-funcs flag-o-matic multilib

DESCRIPTION="Java Native Access (JNA)"
HOMEPAGE="https://jna.dev.java.net/"
# repack and mirror
#SRC_URI="http://jna.dev.java.net/source/browse/*checkout*/jna/tags/${PV}/jnalib/dist/src.zip"
SRC_URI="mirror://gentoo/${P}.tar.bz2"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND="virtual/libffi
	>=virtual/jre-1.4"

DEPEND="virtual/libffi
	virtual/pkgconfig
	!test? ( >=virtual/jdk-1.4 )
	test? (
		dev-java/ant-junit
		dev-java/ant-trax
		>=virtual/jdk-1.5
	)"

JAVA_ANT_REWRITE_CLASSPATH="true"

java_prepare() {
	# remove bundled libffi
	rm -rf native/libffi || die

	# respect CFLAGS, don't inhibit warnings, honour CC
	epatch "${FILESDIR}/makefile-flags.patch"

	# ... and also on Solaris platforms
	sed -i -e '100,$s/SunOS/SunOSWithoutPrefix/g' build.xml || die
	# ... and Darwin
	sed -i -e 's:/Developer:/no-way/dont/do/this:g' build.xml || die

	# bug #272054
	append-cflags $(pkg-config --cflags-only-I libffi)

	# Fetch our own prebuilt libffi.
	mkdir -p build/native/libffi/.libs || die
	ln -snf "${EPREFIX}/usr/$(get_libdir)/libffi$(get_libname)" \
		build/native/libffi/.libs/libffi_convenience.a || die

	# Build to same directory on 64-bit archs.
	ln -snf build build-d64 || die
}

src_install() {
	java-pkg_dojar build/${PN}.jar
	java-pkg_doso build/native/libjnidispatch.so # this will break on osx
	use source && java-pkg_dosrc src/com
	use doc && java-pkg_dojavadoc doc/javadoc
}

src_test() {
	unset DISPLAY
	ANT_TASKS="ant-junit ant-nodeps ant-trax" ANT_OPTS="-Djava.awt.headless=true" eant test
}
