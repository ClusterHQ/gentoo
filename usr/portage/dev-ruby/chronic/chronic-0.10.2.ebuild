# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/chronic/chronic-0.10.2.ebuild,v 1.4 2014/08/05 16:00:28 mrueg Exp $

EAPI=5
USE_RUBY="ruby19 ruby20 ruby21 jruby"

RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_EXTRADOC="HISTORY.md README.md"

RUBY_FAKEGEM_GEMSPEC="chronic.gemspec"

inherit ruby-fakegem

DESCRIPTION="Chronic is a natural language date/time parser written in pure Ruby"
HOMEPAGE="https://github.com/mojombo/chronic"
LICENSE="MIT"

KEYWORDS="~amd64 ~x86 ~x86-fbsd"
SLOT="0"
IUSE=""

ruby_add_bdepend "test? ( >=dev-ruby/minitest-5 )"

all_ruby_prepare() {
	sed -i -e '/git ls-files/d' chronic.gemspec || die
}

each_ruby_prepare() {
	case ${RUBY} in
		*jruby)
			# Two tests error when using ruby18, however the library still
			# functions correctly: https://github.com/mojombo/chronic/issues/219
			# The same tests also fail on jruby1.6
			sed -i -e '/def test_time/,+9d' test/test_chronic.rb || die
			sed -i -e '/def test_handle_generic/,+29d' test/test_parsing.rb || die
			;;
		*)
			;;
	esac
}
