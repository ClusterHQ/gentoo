# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/daemons/daemons-1.1.9-r1.ebuild,v 1.3 2014/07/10 11:39:42 graaff Exp $

EAPI=5
USE_RUBY="ruby19 ruby20 ruby21 jruby"

RUBY_FAKEGEM_EXTRADOC="Releases README TODO"
RUBY_FAKEGEM_DOCDIR="html"

RUBY_FAKEGEM_TASK_TEST=""

inherit ruby-fakegem

DESCRIPTION="Wrap existing ruby scripts to be run as a daemon"
HOMEPAGE="http://daemons.rubyforge.org/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="examples"

all_ruby_prepare() {
	sed -e '/gempackagetask/ s:^:#:' \
		-e '/GemPackageTask/,/end/ s:^:#:' \
		-e 's:rake/rdoctask:rdoc/task:' \
		-i Rakefile || die
}

all_ruby_install() {
	all_fakegem_install

	use examples || return

	insinto /usr/share/doc/${PF}/
	doins -r examples
}
