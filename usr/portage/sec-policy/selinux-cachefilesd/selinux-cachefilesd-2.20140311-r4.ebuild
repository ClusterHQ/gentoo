# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sec-policy/selinux-cachefilesd/selinux-cachefilesd-2.20140311-r4.ebuild,v 1.1 2014/08/01 21:04:32 swift Exp $
EAPI="5"

IUSE=""
MODS="cachefilesd"
BASEPOL="2.20140311-r4"

inherit selinux-policy-2

DESCRIPTION="SELinux policy for cachefilesd"

KEYWORDS="~amd64 ~x86"
