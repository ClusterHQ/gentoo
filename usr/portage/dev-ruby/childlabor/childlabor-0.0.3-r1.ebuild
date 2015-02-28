# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/childlabor/childlabor-0.0.3-r1.ebuild,v 1.4 2014/08/12 18:39:09 blueness Exp $

EAPI=5
USE_RUBY="ruby19 ruby20 ruby21 jruby"

RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_TASK_TEST=""
RUBY_FAKEGEM_DOCDIR=""
RUBY_FAKEGEM_EXTRADOC="README.md"

inherit ruby-fakegem

DESCRIPTION="A scripting framework that replaces rake and sake"
HOMEPAGE="https://github.com/carllerche/childlabor"
COMMIT_ID="6518b939dddbad20c7f05aa075d76e3ca6e70447"
SRC_URI="https://github.com/carllerche/childlabor/archive/${COMMIT_ID}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86"
IUSE="test"

RUBY_S="${PN}-${COMMIT_ID}"

ruby_add_bdepend "test? ( dev-ruby/rspec )"

all_ruby_prepare() {
	# Avoid failing spec. The signals work, but the stdout handling
	# doesn't seem to play nice with portage.
	sed -i -e '/can send signals/,/^  end/ s:^:#:' spec/task_spec.rb || die
}

each_ruby_test() {
	${RUBY} -I. -Ilib -S rspec spec/task_spec.rb || die
}
