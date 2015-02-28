# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/libxml/libxml-2.7.0-r2.ebuild,v 1.4 2014/08/05 16:00:44 mrueg Exp $

EAPI=5

USE_RUBY="ruby19 ruby20 ruby21"

RUBY_FAKEGEM_NAME="libxml-ruby"

RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_EXTRADOC="README.rdoc HISTORY"

RUBY_FAKEGEM_TASK_TEST="none"

inherit ruby-fakegem

DESCRIPTION="Ruby libxml with a user friendly API, akin to REXML, but feature complete and significantly faster"
HOMEPAGE="https://github.com/xml4r/libxml-ruby"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ppc ~ppc64 ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="${RDEPEND} dev-libs/libxml2"
DEPEND="${DEPEND} dev-libs/libxml2"

ruby_add_bdepend "doc? ( dev-ruby/rdoc )"

all_ruby_prepare() {
	# Remove grancher tasks only needed for publishing the website
	sed -i -e '/grancher/d' -e '/Grancher/,$d' Rakefile || die

	# We don't have the hanna template available.
	sed -i -e 's/hanna/rake/' Rakefile || die

	# Remove rake-compiler bits since we don't use it
	sed -i -e '/extensiontask/d' -e '/ExtensionTask/,/end/d' -e '/GemPackageTask/,/end/d' Rakefile || die

	# replace ulimit -n output as it does not work with Ruby 1.9
	sed -i -e 's:`ulimit -n`:"'`ulimit -n`'":' test/tc_parser.rb || die

	# Avoid test failing due to different semantics in libxml 2.8.
	# https://github.com/xml4r/libxml-ruby/issues/43
	sed -i -e '/test_invalid_encoding/,/^  end/ s:^:#:' test/tc_reader.rb || die

	# Ignore two test failures on ruby18 for now given that older
	# versions no longer compile.
	sed -i -e '/test_schema_type/,/end/ s:^:#:' \
		-e '/test_schema_element/,/end/ s:^:#:' test/tc_schema.rb || die

	# Remove the pregenerated extconf.h. It should not be included, but
	# it also confuses our hardlink-based duplication scheme.
	rm ext/libxml/extconf.h || die
}

each_ruby_configure() {
	${RUBY} -C ext/libxml extconf.rb || die
}

each_ruby_compile() {
	emake -C ext/libxml V=1
	cp ext/libxml/libxml_ruby.so lib/ || die
}

each_ruby_test() {
	# The test suite needs to load its files in alphabetical order but
	# this is not guaranteed. See bug 370501.
	${RUBY} -Ilib -r ./test/test_helper.rb test/test_suite.rb || die
}
