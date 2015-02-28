# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ammeter/ammeter-0.2.9-r1.ebuild,v 1.1 2014/05/27 07:42:17 graaff Exp $

EAPI=5
USE_RUBY="ruby19 ruby20"

RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_RECIPE_TEST="rspec"

RUBY_FAKEGEM_EXTRADOC="README.md"

RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"

inherit ruby-fakegem

DESCRIPTION="Write specs for your Rails 3+ generators"
HOMEPAGE="https://github.com/alexrothenberg/ammeter"
LICENSE="MIT"

SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

ruby_add_rdepend "
	>=dev-ruby/activesupport-3.0
	>=dev-ruby/railties-3.0
	>=dev-ruby/rspec-2.2
	>=dev-ruby/rspec-rails-2.2
"

ruby_add_bdepend "
	test? (
		>=dev-ruby/rails-3.1
		<dev-ruby/rails-4.1
		dev-ruby/uglifier
		dev-ruby/rake
		dev-ruby/coffee-rails
		dev-ruby/sass-rails
		dev-ruby/jquery-rails
		dev-util/cucumber
		dev-util/aruba
		dev-ruby/sqlite3
		dev-ruby/bundler
	)"

all_ruby_prepare() {
	# fix the gemspec; we remove the version dependencies from there, as
	# it requires _older_ versions of its dependencies.. it doesn't
	# really seem to be the case though. Also remove the references to
	# git ls-files to avoid calling it.
	sed -i \
		-e '/git ls-files/d' \
		-e '/\(cucumber\|aruba\)/s:,.*$::' \
		${RUBY_FAKEGEM_GEMSPEC} || die

	# Specs are not compatible with Rails 4.1
	sed -i -e '23i   s.add_development_dependency "rails", "<4.1"' ${RUBY_FAKEGEM_GEMSPEC} || die
}

each_ruby_test() {
	${RUBY} -S bundle exec ${RUBY} -S rspec spec || die
}
