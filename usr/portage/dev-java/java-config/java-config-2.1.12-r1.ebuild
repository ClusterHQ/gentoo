# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/java-config/java-config-2.1.12-r1.ebuild,v 1.9 2013/09/05 18:27:44 mgorny Exp $

EAPI="5"

# jython depends on java-config, so don't add it or things will breake.
PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3} )

inherit distutils-r1 eutils fdo-mime gnome2-utils prefix

DESCRIPTION="Java environment configuration tool"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
# this needs testing/checking/updating
#KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=">=dev-java/java-config-wrapper-0.15
	!sys-apps/baselayout-java
	!app-admin/eselect-java"
# https://bugs.gentoo.org/show_bug.cgi?id=315229
PDEPEND=">=virtual/jre-1.5"
# Tests fail when java-config isn't already installed.
RESTRICT="test"

python_test() {
	"${PYTHON}" src/run-test-suite.py || die
	"${PYTHON}" src/run-test-suite2.py || die
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify \
		config/20java-config setup.py \
		src/{depend-java-query,gjl,java-config-2,launcher.bash,run-java-tool} \
		src/eselect/java-{nsplugin,vm}.eselect \
		src/profile.d/java-config-2.{,c}sh \
		src/java_config_2/{EnvironmentManager.py,VM.py,VersionManager.py} \
		man/java-config-2.1
}

python_install_all() {
	distutils-r1_python_install_all

	local a=${ARCH}
	case $a in
		*-hpux)       a=hpux;;
		*-linux)      a=${a%-linux};;
		amd64-fbsd)   a=x64-freebsd;;
	esac

	insinto /usr/share/java-config-2/config/
	newins config/jdk-defaults-${a}.conf jdk-defaults.conf
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
