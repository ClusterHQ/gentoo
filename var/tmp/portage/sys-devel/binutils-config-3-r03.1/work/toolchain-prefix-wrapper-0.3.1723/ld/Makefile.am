# Copyright 2007-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Author: Michael Haubenwallner <haubi@gentoo.org>

libmiscdir = ${libdir}/misc/binutils-config

libmisc_SCRIPTS = create-ldwrapper

libmisc_LIBRARIES = libbinutils-config.a
libbinutils_config_a_SOURCES = ldwrapper.c

libbinutils_config_a_SOURCES += ldplugin.h binutils-config.h
libbinutils_config_a_SOURCES += darwinplugin.c darwinplugin.h
libbinutils_config_a_SOURCES += aixplugin.c aixplugin.h
libbinutils_config_a_SOURCES += hpuxplugin.c hpuxplugin.h
libbinutils_config_a_SOURCES += gnuplugin.c gnuplugin.h
libbinutils_config_a_SOURCES += solarisplugin.c solarisplugin.h
libbinutils_config_a_SOURCES += $(top_srcdir)/utils/stringutil.c
libbinutils_config_a_SOURCES += $(top_srcdir)/utils/stringutil.h
libbinutils_config_a_SOURCES += $(top_srcdir)/utils/textfile.c
libbinutils_config_a_SOURCES += $(top_srcdir)/utils/textfile.h

libmisc_HEADERS = binutils-config.h

libbinutils_config_a_CPPFLAGS = -I$(top_srcdir)/utils

MAINTAINERCLEANFILES = Makefile.in
