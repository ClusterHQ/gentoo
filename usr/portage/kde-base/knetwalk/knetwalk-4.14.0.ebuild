# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/knetwalk/knetwalk-4.14.0.ebuild,v 1.1 2014/08/20 16:02:45 johu Exp $

EAPI=5

KDE_HANDBOOK="optional"
inherit kde4-base

DESCRIPTION="KDE: Knetwalk is the kde version of the popular NetWalk game for system administrators"
HOMEPAGE="
	http://www.kde.org/applications/games/knetwalk/
	http://games.kde.org/game.php?game=knetwalk
"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux"
IUSE="debug"

DEPEND="$(add_kdebase_dep libkdegames)"
RDEPEND="${DEPEND}"
