# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/glib/glib-2.40.0-r1.ebuild,v 1.2 2014/06/18 19:11:16 mgorny Exp $

EAPI="5"
PYTHON_COMPAT=( python2_{6,7} )
# Avoid runtime dependency on python when USE=test

inherit autotools bash-completion-r1 gnome.org libtool eutils flag-o-matic gnome2-utils multilib pax-utils python-r1 toolchain-funcs versionator virtualx linux-info multilib-minimal

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="http://www.gtk.org/"
SRC_URI="${SRC_URI}
	http://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz" # pkg.m4 for eautoreconf

LICENSE="LGPL-2+"
SLOT="2"
IUSE="debug fam kernel_linux +mime selinux static-libs systemtap test utils xattr"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"

# FIXME: want >=libselinux-2.2.2-r4[${MULTILIB_USEDEP}] - bug #480960
RDEPEND="
	>=virtual/libiconv-0-r1[${MULTILIB_USEDEP}]
	>=virtual/libffi-3.0.13-r1[${MULTILIB_USEDEP}]
	>=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}]
	kernel_linux? ( || (
		>=dev-libs/elfutils-0.142
		>=dev-libs/libelf-0.8.12
		>=sys-freebsd/freebsd-lib-9.2_rc1
		) )
	selinux? ( sys-libs/libselinux )
	x86-interix? ( sys-libs/itx-bind )
	xattr? ( >=sys-apps/attr-2.4.47-r1[${MULTILIB_USEDEP}] )
	fam? ( >=virtual/fam-0-r1[${MULTILIB_USEDEP}] )
	utils? (
		${PYTHON_DEPS}
		>=dev-util/gdbus-codegen-${PV}[${PYTHON_USEDEP}] )
	abi_x86_32? (
		!<=app-emulation/emul-linux-x86-baselibs-20130224-r9
		!app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)]
	)
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	app-text/docbook-xml-dtd:4.1.2
	>=dev-libs/libxslt-1.0
	>=sys-devel/gettext-0.11
	>=dev-util/gtk-doc-am-1.20
	systemtap? ( >=dev-util/systemtap-1.3 )
	test? (
		sys-devel/gdb
		${PYTHON_DEPS}
		>=dev-util/gdbus-codegen-${PV}[${PYTHON_USEDEP}]
		>=sys-apps/dbus-1.2.14 )
	!<dev-libs/gobject-introspection-1.$(get_version_component_range 2)
	!<dev-util/gtk-doc-1.15-r2
"
# gobject-introspection blocker to ensure people don't mix
# different g-i and glib major versions
# virtual/pkgconfig due to eautoreconf (and configure most likely) #479276

PDEPEND="!<gnome-base/gvfs-1.6.4-r990
	mime? ( x11-misc/shared-mime-info )
"
# shared-mime-info needed for gio/xdgmime, bug #409481
# Earlier versions of gvfs do not work with glib

DOCS="AUTHORS ChangeLog* NEWS* README"

pkg_setup() {
	if use kernel_linux ; then
		CONFIG_CHECK="~INOTIFY_USER"
		if use test; then
			CONFIG_CHECK="~IPV6"
			WARNING_IPV6="Your kernel needs IPV6 support for running some tests, skipping them."
			export IPV6_DISABLED="yes"
		fi
		linux-info_pkg_setup
	fi
}

src_prepare() {
	# Prevent build failure in stage3 where pkgconfig is not available, bug #481056
	mv -f "${WORKDIR}"/pkg-config-*/pkg.m4 "${S}"/m4macros/ || die

	# patch avoids autoreconf necessity
	epatch "${FILESDIR}"/${PN}-2.32.1-solaris-thread.patch

	# Fix gmodule issues on fbsd; bug #184301, upstream bug #107626
	epatch "${FILESDIR}"/${PN}-2.12.12-fbsd.patch

	epatch "${FILESDIR}"/${PN}-2.39.2-aix.patch # more AIX buildtime fixes

	if use test; then
		# Do not try to remove files on live filesystem, upstream bug #619274
		sed 's:^\(.*"/desktop-app-info/delete".*\):/*\1*/:' \
			-i "${S}"/gio/tests/desktop-app-info.c || die "sed failed"

		# Disable tests requiring dev-util/desktop-file-utils when not installed, bug #286629, upstream bug #629163
		if ! has_version dev-util/desktop-file-utils ; then
			ewarn "Some tests will be skipped due dev-util/desktop-file-utils not being present on your system,"
			ewarn "think on installing it to get these tests run."
			sed -i -e "/appinfo\/associations/d" gio/tests/appinfo.c || die
			sed -i -e "/desktop-app-info\/default/d" gio/tests/desktop-app-info.c || die
			sed -i -e "/desktop-app-info\/fallback/d" gio/tests/desktop-app-info.c || die
			sed -i -e "/desktop-app-info\/lastused/d" gio/tests/desktop-app-info.c || die
		fi

		# gdesktopappinfo requires existing terminal (gnome-terminal or any
		# other), falling back to xterm if one doesn't exist
		if ! has_version x11-terms/xterm && ! has_version x11-terms/gnome-terminal ; then
			ewarn "Some tests will be skipped due to missing terminal program"
			sed -i -e "/appinfo\/launch/d" gio/tests/appinfo.c || die
		fi

		# Disable tests requiring dbus-python and pygobject; bugs #349236, #377549, #384853
		if ! has_version dev-python/dbus-python || ! has_version 'dev-python/pygobject:3' ; then
			ewarn "Some tests will be skipped due to dev-python/dbus-python or dev-python/pygobject:3"
			ewarn "not being present on your system, think on installing them to get these tests run."
			sed -i -e "/connection\/filter/d" gio/tests/gdbus-connection.c || die
			sed -i -e "/connection\/large_message/d" gio/tests/gdbus-connection-slow.c || die
			sed -i -e "/gdbus\/proxy/d" gio/tests/gdbus-proxy.c || die
			sed -i -e "/gdbus\/proxy-well-known-name/d" gio/tests/gdbus-proxy-well-known-name.c || die
			sed -i -e "/gdbus\/introspection-parser/d" gio/tests/gdbus-introspection.c || die
			sed -i -e "/g_test_add_func/d" gio/tests/gdbus-threading.c || die
			sed -i -e "/gdbus\/method-calls-in-thread/d" gio/tests/gdbus-threading.c || die
			# needed to prevent gdbus-threading from asserting
			ln -sfn $(type -P true) gio/tests/gdbus-testserver.py
		fi

		# Some tests need ipv6, upstream bug #667468
		if [[ -n "${IPV6_DISABLED}" ]]; then
			sed -i -e "/socket\/ipv6_sync/d" gio/tests/socket.c || die
			sed -i -e "/socket\/ipv6_async/d" gio/tests/socket.c || die
			sed -i -e "/socket\/ipv6_v4mapped/d" gio/tests/socket.c || die
		fi

		# Test relies on /usr/bin/true, but we have /bin/true, upstream bug #698655
		sed -i -e "s:/usr/bin/true:${EPREFIX}/bin/true:" gio/tests/desktop-app-info.c || die

		# thread test fails, upstream bug #679306
		epatch "${FILESDIR}/${PN}-2.34.0-testsuite-skip-thread4.patch"
	else
		# Don't build tests, also prevents extra deps, bug #512022
		sed -i -e 's/ tests//' {.,gio,glib}/Makefile.am || die
	fi

	# gdbus-codegen is a separate package
	epatch "${FILESDIR}/${PN}-2.40.0-external-gdbus-codegen.patch"

	# do not allow libgobject to unload; bug #405173, https://bugzilla.gnome.org/show_bug.cgi?id=707298
	epatch "${FILESDIR}/${PN}-2.36.4-znodelete.patch"

	# leave python shebang alone
	sed -e '/${PYTHON}/d' \
		-i glib/Makefile.{am,in} || die

	# Gentoo handles completions in a different directory
	sed -i "s|^completiondir =.*|completiondir = $(get_bashcompdir)|" \
		gio/Makefile.am || die

	# Support compilation in clang until upstream solves this, upstream bug #691608
	append-flags -Wno-format-nonliteral

	epatch_user

	# make default sane for us
	if use prefix ; then
		sed -i -e "s:/usr/local:${EPREFIX}/usr:" gio/xdgmime/xdgmime.c || die
		# bug #308609, without path, bug #314057
		export PERL=perl
	fi

	# build glib with parity for native win32
	if [[ ${CHOST} == *-winnt* ]] ; then
		epatch "${FILESDIR}"/${PN}-2.18.3-winnt-lt2.patch
		# makes the iconv check more general, needed for winnt, but could
		# be useful for others too, requires eautoreconf
		epatch "${FILESDIR}"/${PN}-2.18.3-iconv.patch
		epatch "${FILESDIR}"/${PN}-2.20.5-winnt-exeext.patch
#		AT_M4DIR="m4macros" eautoreconf
	fi

	if [[ ${CHOST} == *-interix* ]]; then
		# activate the itx-bind package...
		append-flags "-I${EPREFIX}/usr/include/bind"
		append-libs "-L${EPREFIX}/usr/lib/bind"
	fi

	# Needed for the punt-python-check patch, disabling timeout test
	# Also needed to prevent cross-compile failures, see bug #267603
	# Also needed for the no-gdbus-codegen patch
	eautoreconf

	# FIXME: Really needed when running eautoreconf before? bug#????
	#[[ ${CHOST} == *-freebsd* ]] && elibtoolize

	epunt_cxx
}

multilib_src_configure() {
	# Avoid circular depend with dev-util/pkgconfig and
	# native builds (cross-compiles won't need pkg-config
	# in the target ROOT to work here)
	if ! tc-is-cross-compiler && ! $(tc-getPKG_CONFIG) --version >& /dev/null; then
		if has_version sys-apps/dbus; then
			export DBUS1_CFLAGS="-I${EPREFIX}/usr/include/dbus-1.0 -I${EPREFIX}/usr/$(get_libdir)/dbus-1.0/include"
			export DBUS1_LIBS="-ldbus-1"
		fi
		export LIBFFI_CFLAGS="-I$(echo "${EPREFIX}"/usr/$(get_libdir)/libffi-*/include)"
		export LIBFFI_LIBS="-lffi"
	fi

	local myconf

	case "${CHOST}" in
		*-mingw*) myconf="${myconf} --with-threads=win32" ;;
		*)        myconf="${myconf} --with-threads=posix" ;;
	esac

	# Building with --disable-debug highly unrecommended.  It will build glib in
	# an unusable form as it disables some commonly used API.  Please do not
	# convert this to the use_enable form, as it results in a broken build.
	use debug && myconf="--enable-debug"

	# non-glibc platforms use GNU libiconv, but configure needs to know about
	# that not to get confused when it finds something outside the prefix too
	if use !elibc_glibc ; then
		myconf="${myconf} --with-libiconv=gnu"
		# add the libdir for libtool, otherwise it'll make love with system
		# installed libiconv. Automake passes LDFLAGS before local libs,
		# add this to LIBS instead to come after local lib dirs.
		append-libs "-L${EPREFIX}/usr/$(get_libdir)"
	fi

	[[ ${CHOST} == *-interix* ]] && {
		export ac_cv_func_mmap_fixed_mapped=yes
		export ac_cv_func_poll=no
	}

	local mythreads=posix
	[[ ${CHOST} == *-winnt* ]] && mythreads=win32

	# Only used by the gresource bin
	multilib_is_native_abi || myconf="${myconf} --disable-libelf"

	# FIXME: change to "$(use_enable selinux)" when libselinux is multilibbed, bug #480960
	if multilib_is_native_abi; then
		myconf="${myconf} $(use_enable selinux)"
	else
		myconf="${myconf} --disable-selinux"
	fi

	# Always use internal libpcre, bug #254659
	ECONF_SOURCE="${S}" econf ${myconf} \
		$(use_enable xattr) \
		$(use_enable fam) \
		$(use_enable selinux) \
		$(use_enable static-libs static) \
		$(use_enable systemtap dtrace) \
		$(use_enable systemtap systemtap) \
		--disable-compile-warnings \
		--enable-man \
		--with-pcre=internal \
		--with-threads=${mythreads} \
		--with-xml-catalog="${EPREFIX}/etc/xml/catalog"

	if multilib_is_native_abi; then
		local d
		for d in glib gio gobject; do
			ln -s "${S}"/docs/reference/${d}/html docs/reference/${d}/html || die
		done
	fi
}

multilib_src_install_all() {
	einstalldocs

	if use utils ; then
		python_replicate_script "${ED}"/usr/bin/gtester-report
	else
		rm "${ED}usr/bin/gtester-report"
		rm "${ED}usr/share/man/man1/gtester-report.1"
	fi

	# Don't install gdb python macros, bug 291328
	rm -rf "${ED}/usr/share/gdb/" "${ED}/usr/share/glib-2.0/gdb/"

	# Completely useless with or without USE static-libs, people need to use
	# pkg-config
	prune_libtool_files --modules
}

multilib_src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	export XDG_CONFIG_DIRS="${EPREFIX}"/etc/xdg
	export XDG_DATA_DIRS="${EPREFIX}"/usr/local/share:"${EPREFIX}"/usr/share
	export G_DBUS_COOKIE_SHA1_KEYRING_DIR="${T}/temp"
	export XDG_DATA_HOME="${T}"
	unset GSETTINGS_BACKEND # bug 352451
	export LC_TIME=C # bug #411967
	python_export_best

	# Related test is a bit nitpicking
	mkdir "$G_DBUS_COOKIE_SHA1_KEYRING_DIR"
	chmod 0700 "$G_DBUS_COOKIE_SHA1_KEYRING_DIR"

	# Hardened: gdb needs this, bug #338891
	if host-is-pax ; then
		pax-mark -mr "${BUILD_DIR}"/tests/.libs/assert-msg-test \
			|| die "Hardened adjustment failed"
	fi

	# Need X for dbus-launch session X11 initialization
	Xemake check
}

pkg_postinst() {
	if has_version '<x11-libs/gtk+-3.0.12:3'; then
		# To have a clear upgrade path for gtk+-3.0.x users, have to resort to
		# a warning instead of a blocker
		ewarn
		ewarn "Using <gtk+-3.0.12:3 with ${P} results in frequent crashes."
		ewarn "You should upgrade to a newer version of gtk+:3 immediately."
	fi
}
