# Copyright 2007-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Author: Michael Haubenwallner <haubi@gentoo.org>

AC_INIT(toolchain-prefix-wrapper,0.3.svnversion)
AC_CONFIG_AUX_DIR([build-aux])
AC_PROG_INSTALL
AC_CONFIG_SRCDIR(ld/ldwrapper.c)
AC_PREREQ(2.52)
AC_CANONICAL_HOST
AM_INIT_AUTOMAKE([no-dist-gzip dist-xz])
AC_CONFIG_HEADERS(config.h)
AC_CONFIG_FILES(utils/Makefile ld/Makefile ld/create-ldwrapper Makefile)

AC_PROG_CC

AC_PROG_RANLIB

AC_DEFINE_UNQUOTED([CHOST], ["${ac_cv_host}"], [host the wrapper is running on])

AC_C_INLINE

AC_MSG_CHECKING([for Gentoo Portage EPREFIX])
AC_ARG_WITH([gentoo-portage-eprefix],
	[AC_HELP_STRING(
	 	[--with-gentoo-portage-eprefix],
		[the Gentoo Portage EPREFIX, e.g. '/opt/gentoo']
	)],
	[GENTOO_PORTAGE_EPREFIX=$withval],
	[GENTOO_PORTAGE_EPREFIX=yes]
)
case "x${GENTOO_PORTAGE_EPREFIX}" in
	xyes)
		GENTOO_PORTAGE_EPREFIX=$prefix
		if test "x${GENTOO_PORTAGE_EPREFIX}" = xNONE; then
			GENTOO_PORTAGE_EPREFIX=
		else
			GENTOO_PORTAGE_EPREFIX=`echo "${GENTOO_PORTAGE_EPREFIX}" | sed 's,/usr/*$,,'`
		fi
	;;
	xno) GENTOO_PORTAGE_EPREFIX= ;;
	x/*) ;;
	*) AC_ERROR([need yes, no, or absolute path for --with-gentoo-portage-eprefix])
	;;
esac
case "x${GENTOO_PORTAGE_EPREFIX}" in
	x*/) GENTOO_PORTAGE_EPREFIX=`echo "${GENTOO_PORTAGE_EPREFIX}" | sed 's,/*$,,'` ;;
esac
AC_MSG_RESULT(['${GENTOO_PORTAGE_EPREFIX}'])
AC_DEFINE_UNQUOTED(
	[GENTOO_PORTAGE_EPREFIX], ["${GENTOO_PORTAGE_EPREFIX}"],
	[gentoo portage eprefix]
)
AC_SUBST(GENTOO_PORTAGE_EPREFIX)

AC_MSG_CHECKING([for Mac OS X minimum deployment target])
AC_ARG_WITH([macosx-version-min],
	[AC_HELP_STRING(
	 	[--with-macosx-version-min],
		[the minimum deployment target on Mac OS X, such as 10.4]
	)],
	[MIN_OSX_TARGET=$withval],
	[MIN_OSX_TARGET=auto]
)
# We only "support" Tiger, Leopard and Snow Leopard and Lion
case $ac_cv_host in
	*-darwin*)
		case "x${MIN_OSX_TARGET}" in
			x10.[[3456789]]) ;;
			xno)
				AC_ERROR([--with-macosx-version-min must be given on Mac OS X hosts])
			;;
			xauto)
				# auto guessing
				case $ac_cv_host in
					*-darwin8*)
						MIN_OSX_TARGET=10.4
					;;
					*-darwin9*)
						MIN_OSX_TARGET=10.5
					;;
					*-darwin10*)
						MIN_OSX_TARGET=10.6
					;;
					*-darwin11*)
						MIN_OSX_TARGET=10.7
					;;
				esac
			;;
			*)
				AC_ERROR([need an explicit Mac OS X version number with --with-macosx-version-min])
			;;
		esac
		AC_MSG_RESULT(['${MIN_OSX_TARGET}'])
	;;
	*)
		MIN_OSX_TARGET="you shouldn't use this"
		AC_MSG_RESULT([irrelevant for $ac_cv_host])
	;;
esac
AC_DEFINE_UNQUOTED(
	[MIN_OSX_TARGET], ["${MIN_OSX_TARGET}"],
	[macosx_version_min]
)
AC_SUBST(MIN_OSX_TARGET)

AC_MSG_CHECKING([whether to use native ld even when GNU ld is supported])
AC_ARG_WITH([native-ld],
	[AC_HELP_STRING(
	 	[--with-native-ld],
		[Use the native linker even when GNU linker is supported (Solaris only)]
	)],
	[NATIVELD=${withval}],
	[NATIVELD=no]
)
AC_MSG_RESULT([${NATIVELD}])
AC_SUBST(NATIVELD)

AC_OUTPUT
