# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sec-policy/selinux-pcscd/selinux-pcscd-2.20140311-r1.ebuild,v 1.2 2014/04/19 15:51:21 swift Exp $
EAPI="4"

IUSE=""
MODS="pcscd"
BASEPOL="2.20140311-r1"

inherit selinux-policy-2

DESCRIPTION="SELinux policy for pcscd"

KEYWORDS="amd64 x86"
