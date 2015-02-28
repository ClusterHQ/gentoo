# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/tzinfo/tzinfo-1.2.2.ebuild,v 1.2 2014/08/12 21:28:40 blueness Exp $

EAPI=5
USE_RUBY="ruby19 ruby20 ruby21"

RUBY_FAKEGEM_TASK_TEST="test_zoneinfo"

RUBY_FAKEGEM_RECIPE_DOC="rdoc"
RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_EXTRADOC="CHANGES.md README.md"

inherit ruby-fakegem

DESCRIPTION="Daylight-savings aware timezone library"
HOMEPAGE="http://tzinfo.github.io/"

LICENSE="MIT"
SLOT="1"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ppc ~ppc64 ~x86"
IUSE=""

RDEPEND="sys-libs/timezone-data"
DEPEND="test? ( sys-libs/timezone-data )"

ruby_add_rdepend ">=dev-ruby/thread_safe-0.1:0"
ruby_add_bdepend "test? ( dev-ruby/minitest:5 )"

all_ruby_prepare() {
	# Set the secure permissions that tests expect.
	chmod 0755 "${HOME}" || die "Failed to fix permissions on home"
}
