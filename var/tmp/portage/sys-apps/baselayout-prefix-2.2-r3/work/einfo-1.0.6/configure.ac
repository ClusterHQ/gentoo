#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([einfo], [1.0.6], [prefix@gentoo.org])
AM_INIT_AUTOMAKE([foreign dist-xz no-dist-gzip])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CC
AC_PROG_LN_S
AC_PROG_LIBTOOL

# termcap support for colour codes
HAVE_TERMCAP=
AC_CHECK_HEADER([termcap.h], [HAVE_TERMCAP=yes], [HAVE_TERMCAP=])
if test "x$HAVE_TERMCAP" = "xyes" ; then
	HAVE_TERMCAP=
	AC_CHECK_LIB([ncurses], [tgetent], [HAVE_TERMCAP="-lncurses"],
	  AC_CHECK_LIB([curses], [tgetent], [HAVE_TERMCAP="-lcurses"],
	    AC_CHECK_LIB([termcap], [tgetent], [HAVE_TERMCAP="-ltermcap"])
	  )
	)
fi
AC_DEFINE_UNQUOTED([HAVE_TERMCAP], `test "x$HAVE_TERMCAP" = "x"; echo $?`,
		  [Define if termcap.h and library exist])
AC_SUBST([TERMCAP_LIBS], [$HAVE_TERMCAP])

# Checks for library functions.
AC_CHECK_FUNCS([gettimeofday strcasecmp strrchr strdup strlcpy strlcat vsyslog])
AC_SEARCH_LIBS([nanosleep], [rt])

# Checks for __attribute__((visibility("hidden"))) support
# Check taken from glibc.
AC_CACHE_CHECK(whether __attribute__((visibility("hidden"))) is supported,
	 einfo_cv_visibility_hidden_support,
	 [cat > conftest.c <<EOF
	  int foo __attribute__ ((visibility ("hidden"))) = 1;
EOF
	  einfo_cv_visibility_hidden_support=no
	  if AC_TRY_COMMAND(${CC-cc} -Werror -S conftest.c -o conftest.s 1>&AS_MESSAGE_LOG_FD); then
	    if grep '\.hidden.*foo' conftest.s >/dev/null; then
	      einfo_cv_visibility_hidden_support=yes
	    fi
	  fi
	  rm -f conftest.{c,s}
	 ])
if test $einfo_cv_visibility_hidden_support = yes; then
  AC_DEFINE([HAVE_VISIBILITY_HIDDEN], [1], [Support for visibility(hidden)])
fi

# defines for functions.sh
test "x$exec_prefix" = "xNONE" && exec_prefix=$prefix
eval "dqlibexecdir=\"$libexecdir\""
AC_SUBST([LIBEXECDIR], [$dqlibexecdir])
# defines for einfo.pc
AC_SUBST([PREFIX], [$prefix])
AC_SUBST([INCLUDEDIR], [$includedir])
AC_SUBST([LIBDIR], [$libdir])
AC_SUBST([VERSION], [$PACKAGE_VERSION])

AC_CONFIG_FILES([Makefile
                 man/Makefile
                 pkgconfig/Makefile
				 pkgconfig/einfo.pc
                 sh/Makefile
				 sh/functions.sh
                 src/Makefile
                 src/libeinfo/Makefile
                 src/rc/Makefile])
AC_OUTPUT
