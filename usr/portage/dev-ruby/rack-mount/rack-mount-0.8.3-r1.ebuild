# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rack-mount/rack-mount-0.8.3-r1.ebuild,v 1.3 2014/08/05 16:00:26 mrueg Exp $

EAPI=5
USE_RUBY="ruby19 jruby"

RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_EXTRADOC="README.rdoc"

inherit versionator ruby-fakegem

DESCRIPTION="A stackable dynamic tree based Rack router"
HOMEPAGE="https://github.com/josh/rack-mount"
SRC_URI="https://github.com/josh/rack-mount/tarball/v${PV} -> ${P}.tgz"
RUBY_S="josh-${PN}-*"

LICENSE="MIT"
SLOT="$(get_version_component_range 1-2)"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

ruby_add_rdepend ">=dev-ruby/rack-1.0.0"

all_ruby_prepare() {
	# Avoid fragile test depending on hash ordering.
	sed -i -e '/foo=1&bar=2/ s:^:#:' test/test_utils.rb || die
}
