# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jflex/jflex-1.5.1.ebuild,v 1.2 2014/04/30 15:27:11 tomwij Exp $

EAPI="5"

JAVA_PKG_IUSE="doc source examples"

inherit java-pkg-2 java-ant-2

DESCRIPTION="JFlex is a lexical analyzer generator for Java"
HOMEPAGE="http://www.jflex.de/"
SRC_URI="http://${PN}.de/${P}.tar.gz"

LICENSE="BSD"
SLOT="1.5"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~amd64-fbsd ~ppc-macos ~x64-macos ~x86-macos"

RDEPEND=">=virtual/jre-1.5
	vim-syntax? ( || ( app-editors/vim app-editors/gvim ) )
	>=dev-java/ant-core-1.7.0
	>=dev-java/javacup-0.11a_beta20060608:0"

DEPEND=">=virtual/jdk-1.5
	dev-java/junit:0
	>=dev-java/javacup-0.11a_beta20060608:0"

IUSE="${JAVA_PKG_IUSE} source vim-syntax"

java_prepare() {
	cp "${FILESDIR}"/${PN}-1.5.0-build.xml build.xml || die
}

# TODO: Try to avoid using bundled jar (See bug #498874)
#
# Currently, this package uses an included JFlex.jar file to bootstrap.
# Upstream was contacted and this bootstrap is really needed. The only way to
# avoid it would be to use a supplied pre-compiled .scanner file.

EANT_GENTOO_CLASSPATH="ant-core"
EANT_GENTOO_CLASSPATH_EXTRA="lib/${P}.jar"
JAVA_ANT_REWRITE_CLASSPATH="true"
ANT_TASKS="javacup"

src_compile() {
	java-pkg-2_src_compile

	# Compile another time, using our generated jar; for sanity.
	cp target/${P}.jar ${EANT_GENTOO_CLASSPATH_EXTRA}
	java-pkg-2_src_compile
}

# EANT_TEST_GENTOO_CLASSPATH doesn't support EANT_GENTOO_CLASSPATH_EXTRA yet. 
RESTRICT="test"

src_test() {
	java-pkg-2_src_test
}

src_install() {
	java-pkg_newjar target/${PN}-*.jar ${PN}.jar
	java-pkg_dolauncher "${PN}" --main jflex.Main
	java-pkg_register-ant-task

	if use doc ; then
		dodoc doc/manual.pdf changelog.md
		dohtml -r doc/*
		java-pkg_dojavadoc target/site/apidocs
	fi

	use examples && java-pkg_doexamples examples
	use source && java-pkg_dosrc src/main

	if use vim-syntax; then
		insinto /usr/share/vim/vimfiles/syntax
		doins "${S}/lib/jflex.vim"
	fi
}
