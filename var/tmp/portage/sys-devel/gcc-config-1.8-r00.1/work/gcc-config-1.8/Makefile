CFLAGS ?= -O2 -g
CFLAGS += -Wall -Wextra

PN = gcc-config
PV = git
P = $(PN)-$(PV)

EPREFIX =
PREFIX = $(EPREFIX)/usr
BINDIR = $(PREFIX)/bin
SUBLIBDIR = lib
LIBDIR = $(PREFIX)/$(SUBLIBDIR)
LIBEXECDIR = $(LIBDIR)/misc

MKDIR_P = mkdir -p -m 755
INSTALL_EXE = install -m 755

all: wrapper

wrapper.c: wrapper.c.in
	sed \
		-e 's:@GENTOO_PORTAGE_EPREFIX@:$(EPREFIX):g' \
		wrapper.c.in > wrapper.c

clean:
	rm -f wrapper *.o core

install: all
	$(MKDIR_P) $(DESTDIR)$(BINDIR) $(DESTDIR)$(LIBEXECDIR)
	$(INSTALL_EXE) wrapper $(DESTDIR)$(LIBEXECDIR)/$(PN)
	sed \
		-e 's:@GENTOO_PORTAGE_EPREFIX@:$(EPREFIX):g' \
		-e 's:@GENTOO_LIBDIR@:$(SUBLIBDIR):g' \
		-e 's:@PV@:$(PV):g' \
		gcc-config > $(DESTDIR)$(BINDIR)/gcc-config
	chmod a+rx $(DESTDIR)$(BINDIR)/gcc-config

test check:
	cd tests && ./run_tests

dist:
	@if [ "$(PV)" = "git" ] ; then \
		printf "please run: make dist PV=xxx\n(where xxx is a git tag)\n" ; \
		exit 1 ; \
	fi
	git archive --prefix=$(P)/ v$(PV) | xz > $(P).tar.xz

distcheck: dist
	@set -ex; \
	rm -rf $(P); \
	tar xf $(P).tar.xz; \
	pushd $(P) >/dev/null; \
	$(MAKE) install DESTDIR=`pwd`/foo; \
	rm -rf foo; \
	$(MAKE) check; \
	popd >/dev/null; \
	rm -rf $(P)

.PHONY: all clean dist install
