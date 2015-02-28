# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/preload/preload-0.6.4-r3.ebuild,v 1.1 2012/09/14 19:15:00 pacho Exp $

EAPI=4
inherit eutils autotools prefix

DESCRIPTION="Adaptive readahead daemon."
HOMEPAGE="http://sourceforge.net/projects/preload/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="vanilla"

WANT_AUTOCONF="2.56"

RDEPEND=">=dev-libs/glib-2.6:2"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	sys-apps/help2man"

src_prepare() {
	epatch "${FILESDIR}"/00-patch-configure.diff
	epatch "${FILESDIR}"/02-patch-preload_conf.diff
	epatch "${FILESDIR}"/02-patch-preload_sysconfig.diff
	epatch "${FILESDIR}"/${PN}-0.6.4-use-help2man-as-usual.patch
	epatch "${FILESDIR}"/${PN}-0.6.4-use-make-dependencies.patch
	use vanilla || epatch "${FILESDIR}"/000{1,2,3}-*.patch
	cat "${FILESDIR}"/preload-0.6.4.init.in-r2 > preload.init.in || die

	# Prefix patch
	epatch "${FILESDIR}/${PN}-0.6.3-prefix.patch"
	eprefixify src/preload.conf.in

	eautoreconf
}

src_configure() {
	econf --localstatedir="${EPREFIX}/var"
}

src_install() {
	default

	# Remove log and state file from image or they will be
	# truncated during merge
	rm "${ED}"/var/lib/preload/preload.state || die "cleanup failed"
	rm "${ED}"/var/log/preload.log || die "cleanup failed"
	keepdir /var/lib/preload
	keepdir /var/log
	newinitd "${FILESDIR}/init.d-preload" preload || die "initd failed"
	newconfd "${FILESDIR}/conf.d-preload" preload || die "confd failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}

pkg_postinst() {
	if use !prefix; then
	if [ "$(rc-config list default | grep preload)" = "" ] ; then
		elog "You probably want to add preload to the default runlevel like so:"
		elog "# rc-update add preload default"
	fi
	else
		elog "In prefix, you will have to start preload on the command line"
	fi	

	if has_version sys-fs/e4rat; then
		elog "It appears you have sys-fs/e4rat installed. This may"
		elog "has negative effects on it. You may want to disable preload"
		elog "when using sys-fs/e4rat."
		elog "http://e4rat.sourceforge.net/wiki/index.php/Main_Page#Debian.2FUbuntu"

	fi
}
