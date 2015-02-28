# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/bones/bones-3.8.1-r1.ebuild,v 1.1 2014/05/08 19:13:29 p8952 Exp $

EAPI=5

USE_RUBY="ruby19 ruby20 ruby21 jruby"

RUBY_FAKEGEM_RECIPE_TEST="rspec"

RUBY_FAKEGEM_RECIPE_DOC="rdoc"

RUBY_FAKEGEM_EXTRADOC="History.txt README.rdoc"

RUBY_FAKEGEM_EXTRAINSTALL="default version.txt"

inherit ruby-fakegem

DESCRIPTION="Tool that creates new Ruby projects from a code skeleton"
HOMEPAGE="http://github.com/TwP/bones"

IUSE="test"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

ruby_add_rdepend "
	dev-ruby/builder
	>=dev-ruby/loquacious-1.9.1
	>=dev-ruby/little-plugger-1.1.3
	>=dev-ruby/rake-0.8.7"

all_ruby_prepare() {
	epatch "${FILESDIR}"/${P}-builder.patch
	mv ../metadata .
	epatch "${FILESDIR}"/${P}-rdoc-version.patch
	mv metadata ../
}

each_ruby_test() {
	if [[ ${RUBY} == *jruby ]]; then
		ewarn "JRuby up to 1.6.7.2 is known to crash even after passing the tests."
		return 0
	fi
	each_fakegem_test
}
