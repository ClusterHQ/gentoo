# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sec-policy/selinux-radvd/selinux-radvd-2.20140311-r2.ebuild,v 1.2 2014/05/29 20:23:35 swift Exp $
EAPI="4"

IUSE=""
MODS="radvd"
BASEPOL="2.20140311-r2"

inherit selinux-policy-2

DESCRIPTION="SELinux policy for radvd"

KEYWORDS="amd64 x86"
