# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-embedded/bitbake/bitbake-9999.ebuild,v 1.14 2013/09/05 19:44:53 mgorny Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} )
PYTHON_REQ_USE="sqlite"

inherit distutils-r1 vcs-snapshot

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="git://git.openembedded.org/bitbake.git"
	inherit git-2
	KEYWORDS=""
else
	SRC_URI="https://github.com/openembedded/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~ppc ~x86"
fi

DESCRIPTION="package management tool for OpenEmbedded"
HOMEPAGE="http://developer.berlios.de/projects/bitbake/"

LICENSE="GPL-2"
SLOT="0"
IUSE="doc"

RDEPEND="dev-python/ply
	dev-python/progressbar"
DEPEND="doc? ( dev-libs/libxslt )"

src_prepare() {
	if ! use doc ; then
		sed -i -e 's:doctype = "html":doctype = "none":' \
			-e 's:("share/doc/bitbake-%s/manual.*))::' setup.py || die
		echo "none:" >> doc/manual/Makefile || die
	else
	    sed -i -e "s:\(share/doc/bitbake-%s.* %\) __version__:\1 \"${PV}\":" setup.py || die
	fi
}
