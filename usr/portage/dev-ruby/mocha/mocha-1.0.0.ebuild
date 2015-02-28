# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/mocha/mocha-1.0.0.ebuild,v 1.2 2014/08/12 18:38:09 blueness Exp $

EAPI=5
USE_RUBY="ruby19 ruby20 ruby21 jruby"

RUBY_FAKEGEM_TASK_TEST="test:units"

RUBY_FAKEGEM_TASK_DOC="yardoc"
RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_EXTRADOC="README.md RELEASE.md"

RUBY_FAKEGEM_EXTRAINSTALL="init.rb"

inherit ruby-fakegem

DESCRIPTION="A Ruby library for mocking and stubbing using a syntax like that of JMock, and SchMock"
HOMEPAGE="http://gofreerange.com/mocha/docs/"

LICENSE="MIT"
SLOT="1.0"
KEYWORDS="~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64"
IUSE=""

ruby_add_bdepend "
	doc? ( dev-ruby/yard )
	test? ( >=dev-ruby/test-unit-2.5.1-r1 dev-ruby/introspection )"

ruby_add_rdepend "dev-ruby/metaclass" #metaclass ~> 0.0.1

all_ruby_prepare() {
	sed -i -e '/[Bb]undler/ s:^:#:' -e '1iload "lib/mocha/version.rb"' Rakefile || die
	sed -i -e '20irequire "mocha/setup"' test/test_helper.rb || die
}
