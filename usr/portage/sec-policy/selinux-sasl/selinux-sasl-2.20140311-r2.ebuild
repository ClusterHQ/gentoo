# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sec-policy/selinux-sasl/selinux-sasl-2.20140311-r2.ebuild,v 1.2 2014/05/29 20:23:38 swift Exp $
EAPI="4"

IUSE=""
MODS="sasl"
BASEPOL="2.20140311-r2"

inherit selinux-policy-2

DESCRIPTION="SELinux policy for sasl"

KEYWORDS="amd64 x86"
