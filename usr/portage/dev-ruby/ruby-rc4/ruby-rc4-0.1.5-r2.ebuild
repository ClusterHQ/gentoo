# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby-rc4/ruby-rc4-0.1.5-r2.ebuild,v 1.3 2014/08/19 12:08:12 armin76 Exp $

EAPI=5
USE_RUBY="ruby19 ruby20 ruby21 jruby"

RUBY_FAKEGEM_RECIPE_TEST="rspec"

RUBY_FAKEGEM_DOCDIR="rdoc"
RUBY_FAKEGEM_EXTRADOC="README.md"

inherit ruby-fakegem

DESCRIPTION="A pure Ruby implementation of the Rc4 algorithm"
HOMEPAGE="https://github.com/caiges/Ruby-RC4"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE=""

all_ruby_prepare() {
	sed -i -e 's/"README"/"README.md"/' Rakefile || die
}
