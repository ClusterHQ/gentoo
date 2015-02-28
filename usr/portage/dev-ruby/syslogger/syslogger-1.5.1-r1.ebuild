# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/syslogger/syslogger-1.5.1-r1.ebuild,v 1.2 2014/04/24 16:44:01 mrueg Exp $

EAPI=5
USE_RUBY="ruby19 ruby20 jruby"

RUBY_FAKEGEM_RECIPE_TEST="rspec"

RUBY_FAKEGEM_DOCDIR="rdoc"
RUBY_FAKEGEM_EXTRADOC="README.rdoc"

# if ever needed
#GITHUB_USER="crohr"
#GITHUB_PROJECT="${PN}"

inherit ruby-fakegem

DESCRIPTION="Drop-in replacement for the standard Logger, that logs to the syslog"
HOMEPAGE="https://github.com/crohr/syslogger"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

ruby_add_bdepend "
	doc? ( >=dev-ruby/rdoc-2.4.2 )"

all_ruby_prepare() {
	sed -i '/[Bb]undler/d' Rakefile || die
}
