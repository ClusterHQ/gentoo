# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/refe/refe-0.8.0-r1.ebuild,v 1.5 2014/04/05 23:33:57 mrueg Exp $

EAPI="2"
USE_RUBY="ruby19 jruby"

inherit ruby-ng

DESCRIPTION="ReFe is an interactive reference for Japanese Ruby manual"
HOMEPAGE="http://www.loveruby.net/ja/prog/refe.html"
SRC_URI="http://www.loveruby.net/archive/refe/${P}-withdoc.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc ppc64 x86"
IUSE=""

RUBY_PATCHES=( "${FILESDIR}/${P}-ruby19.patch" )

each_ruby_configure() {
	${RUBY} setup.rb config --data-dir="/usr/share" || die
}

each_ruby_compile() {
	${RUBY} setup.rb setup || die
}

each_ruby_install() {
	${RUBY} setup.rb install --prefix="${D}" || die
}

all_ruby_install() {
	dodoc ChangeLog NEWS README* TODO || die
}
