# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby-oci8/ruby-oci8-2.1.3.ebuild,v 1.4 2014/04/24 17:45:22 mrueg Exp $

EAPI="2"
USE_RUBY="ruby19"

inherit ruby-ng

DESCRIPTION="A Ruby library for Oracle"
HOMEPAGE="http://rubyforge.org/projects/ruby-oci8/"
SRC_URI="mirror://rubyforge/${PN}/${P}.tar.gz"
LICENSE="Ruby"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="dev-db/oracle-instantclient-basic"
DEPEND="${RDEPEND}"

each_ruby_configure() {
	${RUBY} setup.rb config --prefix="${D}/usr" || die "configure failed"
}

each_ruby_compile() {
	${RUBY} setup.rb setup || die "compile failed"
}

each_ruby_install() {
	${RUBY} setup.rb install || die "install failed"
}

all_ruby_install() {
	for i in NEWS README ChangeLog
		do test -e $i && dodoc $i
	done
}

pkg_postinst() {
	test -e "/usr/share/doc/${PF}/NEWS.bz2" && \
		elog "Please read /usr/share/doc/${PF}/NEWS.bz2 for major change information in ${P}"
}
