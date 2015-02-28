# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-php/PEAR-Net_IMAP/PEAR-Net_IMAP-1.1.0_beta1.ebuild,v 1.11 2014/08/10 20:52:28 slyfox Exp $

PEAR_PV="${PV/_/}"

inherit php-pear-r1

DESCRIPTION="Provides an implementation of the IMAP protocol"

LICENSE="PHP-2.02"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ppc ppc64 sparc x86"
IUSE=""
RDEPEND=">=dev-php/PEAR-Net_Socket-1.0.6-r1"
