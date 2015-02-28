# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pypy/pypy-2.3.1-r1.ebuild,v 1.1 2014/07/15 00:34:44 idella4 Exp $

EAPI=5

PYTHON_COMPAT=( python2_7 pypy )
inherit check-reqs eutils multilib multiprocessing pax-utils \
	python-any-r1 toolchain-funcs vcs-snapshot versionator

DESCRIPTION="A fast, compliant alternative implementation of the Python language"
HOMEPAGE="http://pypy.org/"
SRC_URI="https://bitbucket.org/${PN}/${PN}/get/release-${PV}.tar.bz2 -> ${P}-src.tar.bz2"

LICENSE="MIT"
SLOT="0/$(get_version_component_range 1-2 ${PV})"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="bzip2 doc +jit ncurses sandbox shadowstack sqlite sse2 tk"

RDEPEND=">=sys-libs/zlib-1.1.3
	virtual/libffi
	virtual/libintl
	dev-libs/expat
	dev-libs/openssl
	bzip2? ( app-arch/bzip2 )
	ncurses? ( sys-libs/ncurses )
	sqlite? ( dev-db/sqlite:3 )
	tk? (
		dev-lang/tk:0
		dev-tcltk/tix
	)
	!dev-python/pypy-bin:0"
DEPEND="${RDEPEND}
	doc? ( dev-python/sphinx )
	${PYTHON_DEPS}"
PDEPEND="app-admin/python-updater"

S="${WORKDIR}/${P}-src"

pkg_pretend() {
	CHECKREQS_MEMORY="2G"
	use amd64 && CHECKREQS_MEMORY="4G"
	check-reqs_pkg_pretend
}

pkg_setup() {
	pkg_pretend
	python-any-r1_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}/1.9-scripts-location.patch" \
		"${FILESDIR}/1.9-distutils.unixccompiler.UnixCCompiler.runtime_library_dir_option.patch" \
		"${FILESDIR}"/${PV}-shared-lib.patch	# 517002

	pushd lib-python/2.7 > /dev/null || die
	epatch "${FILESDIR}/2.3-21_all_distutils_c++.patch"
	popd > /dev/null || die

	epatch_user
}

src_compile() {
	tc-export CC

	local jit_backend
	if use jit; then
		jit_backend='--jit-backend='

		# We only need the explicit sse2 switch for x86.
		# On other arches we can rely on autodetection which uses
		# compiler macros. Plus, --jit-backend= doesn't accept all
		# the modern values...

		if use x86; then
			if use sse2; then
				jit_backend+=x86
			else
				jit_backend+=x86-without-sse2
			fi
		else
			jit_backend+=auto
		fi
	fi

	local args=(
		--shared
		$(usex jit -Ojit -O2)
		$(usex shadowstack --gcrootfinder=shadowstack '')
		$(usex sandbox --sandbox '')

		${jit_backend}
		--make-jobs=$(makeopts_jobs)

		pypy/goal/targetpypystandalone
	)

	# Avoid linking against libraries disabled by use flags
	local opts=(
		bzip2:bz2
		ncurses:_minimal_curses
	)

	local opt
	for opt in "${opts[@]}"; do
		local flag=${opt%:*}
		local mod=${opt#*:}

		args+=(
			$(usex ${flag} --withmod --withoutmod)-${mod}
		)
	done

	set -- "${PYTHON}" rpython/bin/rpython --batch "${args[@]}"
	echo -e "\033[1m${@}\033[0m"
	"${@}" || die "compile error"

	use doc && emake -C pypy/doc/ html
	pax-mark m "${ED%/}${INSDESTTREE}/pypy-c"
}

src_test() {
	# (unset)
	local -x PYTHONDONTWRITEBYTECODE

	./pypy-c ./pypy/test_all.py --pypy=./pypy-c lib-python || die
}

src_install() {
	einfo "Installing PyPy ..."
	insinto "/usr/$(get_libdir)/pypy"
	doins -r include lib_pypy lib-python pypy-c libpypy-c.so
	fperms a+x ${INSDESTTREE}/pypy-c ${INSDESTTREE}/libpypy-c.so
	pax-mark m "${ED%/}${INSDESTTREE}/pypy-c" "${ED%/}${INSDESTTREE}/libpypy-c.so"
	dosym ../$(get_libdir)/pypy/pypy-c /usr/bin/pypy
	dodoc README.rst

	if ! use sqlite; then
		rm -r "${ED%/}${INSDESTTREE}"/lib-python/*2.7/sqlite3 \
			"${ED%/}${INSDESTTREE}"/lib_pypy/_sqlite3.py \
			"${ED%/}${INSDESTTREE}"/lib-python/*2.7/test/test_sqlite.py || die
	fi
	if ! use tk; then
		rm -r "${ED%/}${INSDESTTREE}"/lib-python/*2.7/{idlelib,lib-tk} \
			"${ED%/}${INSDESTTREE}"/lib_pypy/_tkinter \
			"${ED%/}${INSDESTTREE}"/lib-python/*2.7/test/test_{tcl,tk,ttk*}.py || die
	fi

	# Install docs
	use doc && dohtml -r pypy/doc/_build/html/

	einfo "Generating caches and byte-compiling ..."

	python_export pypy EPYTHON PYTHON PYTHON_SITEDIR
	local PYTHON=${ED%/}${INSDESTTREE}/pypy-c
	local -x LD_LIBRARY_PATH="${ED%/}${INSDESTTREE}"

	echo "EPYTHON='${EPYTHON}'" > epython.py
	python_domodule epython.py

	# Generate Grammar and PatternGrammar pickles.
	"${PYTHON}" -c "import lib2to3.pygram, lib2to3.patcomp; lib2to3.patcomp.PatternCompiler()" \
		|| die "Generation of Grammar and PatternGrammar pickles failed"

	# Generate cffi cache
	"${PYTHON}" -c "import _curses" || die "Failed to import _curses (cffi)"
	"${PYTHON}" -c "import syslog" || die "Failed to import syslog (cffi)"
	if use sqlite; then
		"${PYTHON}" -c "import _sqlite3" || die "Failed to import _sqlite3 (cffi)"
	fi
	if use tk; then
		"${PYTHON}" -c "import _tkinter" || die "Failed to import _tkinter (cffi)"
	fi

	# Cleanup temporary objects
	find "${ED%/}${INSDESTTREE}" -name "_cffi_*.[co]" -delete || die
	find "${ED%/}${INSDESTTREE}" -type d -empty -delete || die

	# compile the installed modules
	python_optimize "${ED%/}${INSDESTTREE}"
}
