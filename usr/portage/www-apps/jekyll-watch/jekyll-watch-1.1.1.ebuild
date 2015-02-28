# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-apps/jekyll-watch/jekyll-watch-1.1.1.ebuild,v 1.1 2014/09/08 22:44:22 mrueg Exp $

EAPI=5
USE_RUBY="ruby19 ruby20"

RUBY_FAKEGEM_RECIPE_TEST="rspec"
RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_EXTRADOC="README.md History.markdown"

inherit ruby-fakegem

DESCRIPTION="Rebuild your Jekyll site when a file changes with the --watch switch"
HOMEPAGE="https://github.com/jekyll/jekyll-watch"
SRC_URI="https://github.com/jekyll/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

ruby_add_rdepend ">=dev-ruby/listen-2.7"
ruby_add_bdepend "test? ( >=www-apps/jekyll-2 )"

all_ruby_prepare() {
	rm Rakefile || die
	# Fix tests until Rspec:3 is in tree
	sed -i -e "/default_formatter/d" -e "/verify_partial_doubles/d" spec/spec_helper.rb || die
}
