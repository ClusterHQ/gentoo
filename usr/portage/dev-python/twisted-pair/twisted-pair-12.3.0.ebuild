# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/twisted-pair/twisted-pair-12.3.0.ebuild,v 1.5 2013/11/24 18:37:34 ago Exp $

EAPI="4"
PYTHON_DEPEND="2:2.6"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.* 2.5 *-jython"
MY_PACKAGE="Pair"

inherit twisted versionator

DESCRIPTION="Twisted low-level networking"

KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND="=dev-python/twisted-core-$(get_version_component_range 1-2)*
	dev-python/eunuchs"
RDEPEND="${DEPEND}"

PYTHON_MODNAME="twisted/pair"
