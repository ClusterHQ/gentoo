# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/htmlentities/htmlentities-4.3.1-r1.ebuild,v 1.4 2014/05/21 02:28:24 mrueg Exp $

EAPI=5

USE_RUBY="ruby19 ruby20 jruby"

RUBY_FAKEGEM_TASK_TEST=""
RUBY_FAKEGEM_TASK_DOC=""

RUBY_FAKEGEM_EXTRADOC="History.txt"

inherit ruby-fakegem

DESCRIPTION="A simple library for encoding/decoding entities in (X)HTML documents"
HOMEPAGE="http://htmlentities.rubyforge.org/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86 ~x86-macos"
IUSE=""

each_ruby_test() {
	${RUBY} -Ilib:. -S testrb test/*_test.rb || die "tests failed"
}
