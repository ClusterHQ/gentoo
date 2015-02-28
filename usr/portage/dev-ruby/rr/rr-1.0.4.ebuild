# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rr/rr-1.0.4.ebuild,v 1.16 2014/04/05 15:01:42 mrueg Exp $

EAPI=4

USE_RUBY="ruby19 jruby"

RUBY_FAKEGEM_TASK_TEST="none"

RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_EXTRADOC="CHANGES README.rdoc"

inherit ruby-fakegem

DESCRIPTION="A double framework that features a rich selection of double techniques and a terse syntax"
HOMEPAGE="http://pivotallabs.com/"
SRC_URI="http://github.com/btakita/${PN}/tarball/v${PV} -> ${P}.tar.gz"

RUBY_S="btakita-${PN}-*"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

ruby_add_bdepend "test? (
		dev-ruby/rspec:0
		dev-ruby/minitest
		dev-ruby/session
		dev-ruby/diff-lcs )"

all_ruby_prepare() {
	rm Gemfile || die
	sed -i -e '/bundler/d' spec/spec_suite.rb spec/environment_fixture_setup.rb || die
}

each_ruby_test() {
	# We need to run everything manually since the Rakefile and
	# associated suite files are riddled with direct invocations of
	# ruby.
	${RUBY} spec/core_spec_suite.rb --format progress || die
	${RUBY} spec/rspec_spec_suite.rb --format progress || die
	${RUBY} spec/test_unit_spec_suite.rb || die
	${RUBY} spec/minitest_spec_suite.rb || die
}
