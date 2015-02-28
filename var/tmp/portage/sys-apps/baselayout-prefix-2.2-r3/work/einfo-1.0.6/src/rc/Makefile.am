bindir = $(libexecdir)/bin
bin_PROGRAMS = einfo
einfo_SOURCES = main.c rc-applets.c
einfo_CPPFLAGS = -I$(srcdir)/../libeinfo -I$(srcdir)/../includes
einfo_LDADD = ../libeinfo/libeinfo.la

RC_BINLINKS = \
			  einfon ewarnn ewarn eerrorn eerror ebegin eend ewend \
			  eindent eoutdent esyslog eval_ecolors ewaitfile \
			  veinfo vewarn vebegin veend vewend veindent veoutdent

install-exec-hook:
	cd "$(DESTDIR)$(bindir)" && \
		for prg in $(RC_BINLINKS) ; do \
			$(LN_S) einfo$(EXEEXT) $${prg}$(EXEEXT); \
		done
