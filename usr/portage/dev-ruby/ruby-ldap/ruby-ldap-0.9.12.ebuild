# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby-ldap/ruby-ldap-0.9.12.ebuild,v 1.8 2014/06/03 19:39:16 graaff Exp $

EAPI="4"
# jruby: mkmf
# rbx: require 'ldap' no such file to load
USE_RUBY="ruby19"

RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_TASK_TEST=""
RUBY_FAKEGEM_EXTRADOC="ChangeLog FAQ NOTES README TODO"

inherit ruby-fakegem

DESCRIPTION="A Ruby interface to some LDAP libraries"
HOMEPAGE="http://ruby-ldap.sourceforge.net/"
SRC_URI="mirror://rubygems/${P}.gem"
LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ppc ~ppc64 sparc x86 ~x86-macos"
IUSE="ssl"
DEPEND=">=net-nds/openldap-2
	dev-libs/cyrus-sasl
	ssl? ( dev-libs/openssl )"
RDEPEND="${DEPEND}"

# Current test set is interactive due to certificate generation and requires
# running LDAP daemon
RESTRICT="test"

each_ruby_configure() {
	local myconf="--with-openldap2"
	if ! use ssl ; then
		myconf="${myconf} --without-libcrypto --without-libssl"
	fi
	${RUBY} extconf.rb ${myconf} || die "extconf.rb failed"
	sed -i -e 's:-Wl,--no-undefined::' \
		-e "s/^ldflags  = /ldflags = $\(LDFLAGS\) /" Makefile || die
}

each_ruby_compile() {
	emake || die
	cp ldap.so lib/
}
