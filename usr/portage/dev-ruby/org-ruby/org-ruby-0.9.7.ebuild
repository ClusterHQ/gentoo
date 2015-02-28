# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/org-ruby/org-ruby-0.9.7.ebuild,v 1.1 2014/07/25 05:27:18 graaff Exp $

EAPI=5
USE_RUBY="ruby19 ruby20 ruby21"

RUBY_FAKEGEM_RECIPE_TEST="rspec"
RUBY_FAKEGEM_RECIPE_DOC="none"
RUBY_FAKEGEM_EXTRADOC="README.org History.org"

inherit ruby-fakegem

DESCRIPTION="Ruby routines for parsing org-mode files"
HOMEPAGE="https://github.com/wallyqs/org-ruby"
SRC_URI="https://github.com/wallyqs/${PN}/archive/version-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RUBY_S="${PN}-version-${PV}"

ruby_add_rdepend "=dev-ruby/rubypants-0.2*:0"
ruby_add_bdepend "test? ( dev-ruby/tilt )"
