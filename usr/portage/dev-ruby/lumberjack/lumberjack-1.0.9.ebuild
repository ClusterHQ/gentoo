# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/lumberjack/lumberjack-1.0.9.ebuild,v 1.1 2014/08/06 06:27:12 mrueg Exp $

EAPI=5
USE_RUBY="ruby19 ruby20 ruby21"

RUBY_FAKEGEM_RECIPE_TEST="rspec"
RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_EXTRADOC="README.rdoc"

inherit ruby-fakegem

DESCRIPTION="A simple, powerful, and very fast logging utility"
HOMEPAGE="http://github.com/bdurand/lumberjack"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
