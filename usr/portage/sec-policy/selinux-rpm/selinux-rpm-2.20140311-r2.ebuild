# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sec-policy/selinux-rpm/selinux-rpm-2.20140311-r2.ebuild,v 1.2 2014/05/29 20:23:41 swift Exp $
EAPI="4"

IUSE=""
MODS="rpm"
BASEPOL="2.20140311-r2"

inherit selinux-policy-2

DESCRIPTION="SELinux policy for rpm"

KEYWORDS="amd64 x86"
