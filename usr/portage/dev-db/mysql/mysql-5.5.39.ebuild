# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/mysql/mysql-5.5.39.ebuild,v 1.10 2014/08/13 15:26:18 maekke Exp $

EAPI="5"

MY_EXTRAS_VER="20140801-1950Z"
MY_PV="${PV//_alpha_pre/-m}"
MY_PV="${MY_PV//_/-}"

# Build type
BUILD="cmake"

inherit toolchain-funcs mysql-v2
# only to make repoman happy. it is really set in the eclass
IUSE="$IUSE"

# Define the mysql-extras source
EGIT_REPO_URI="git://git.overlays.gentoo.org/proj/mysql-extras.git"

# REMEMBER: also update eclass/mysql*.eclass before committing!
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 ~s390 ~sh sparc x86 ~sparc-fbsd ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"

# When MY_EXTRAS is bumped, the index should be revised to exclude these.
EPATCH_EXCLUDE=''

DEPEND="|| ( >=sys-devel/gcc-3.4.6 >=sys-devel/gcc-apple-4.0 )"
RDEPEND="${RDEPEND}"

# Please do not add a naive src_unpack to this ebuild
# If you want to add a single patch, copy the ebuild to an overlay
# and create your own mysql-extras tarball, looking at 000_index.txt

# Official test instructions:
# USE='-cluster embedded extraengine perl ssl static-libs community' \
# FEATURES='test userpriv -usersandbox' \
# ebuild mysql-X.X.XX.ebuild \
# digest clean package
src_test() {

	local TESTDIR="${CMAKE_BUILD_DIR}/mysql-test"
	local retstatus_unit
	local retstatus_tests

	# Bug #213475 - MySQL _will_ object strenously if your machine is named
	# localhost. Also causes weird failures.
	[[ "${HOSTNAME}" == "localhost" ]] && die "Your machine must NOT be named localhost"

	if ! use "minimal" ; then

		if [[ $UID -eq 0 ]]; then
			die "Testing with FEATURES=-userpriv is no longer supported by upstream. Tests MUST be run as non-root."
		fi
		has usersandbox $FEATURES && eerror "Some tests may fail with FEATURES=usersandbox"

		einfo ">>> Test phase [test]: ${CATEGORY}/${PF}"
		addpredict /this-dir-does-not-exist/t9.MYI

		# Run CTest (test-units)
		cmake-utils_src_test
		retstatus_unit=$?
		[[ $retstatus_unit -eq 0 ]] || eerror "test-unit failed"

		# Ensure that parallel runs don't die
		export MTR_BUILD_THREAD="$((${RANDOM} % 100))"

		# create directories because mysqladmin might right out of order
		mkdir -p "${S}"/mysql-test/var-tests{,/log}

		# create symlink for the tests to find mysql_tzinfo_to_sql
		ln -s "${CMAKE_BUILD_DIR}/sql/mysql_tzinfo_to_sql" "${S}/sql/"

		# These are failing in MySQL 5.5 for now and are believed to be
		# false positives:
		#
		# main.information_schema, binlog.binlog_statement_insert_delayed,
		# main.mysqld--help-notwin
		# fails due to USE=-latin1 / utf8 default
		#
		# main.mysql_client_test:
		# segfaults at random under Portage only, suspect resource limits.
		#
		# sys_vars.plugin_dir_basic
		# fails because PLUGIN_DIR is set to MYSQL_LIBDIR64/plugin
		# instead of MYSQL_LIBDIR/plugin
		#
		# main.flush_read_lock_kill
		# fails because of unknown system variable 'DEBUG_SYNC'
		#
		# main.openssl_1
		# error message changing
		# -mysqltest: Could not open connection 'default': 2026 SSL connection
		#  error: ASN: bad other signature confirmation
		# +mysqltest: Could not open connection 'default': 2026 SSL connection
		#  error: error:00000001:lib(0):func(0):reason(1)
		#
		# main.mysql_tzinfo_to_sql_symlink
		# fails due to missing mysql_test/std_data/zoneinfo/GMT file from archive

		for t in main.mysql_client_test \
			binlog.binlog_statement_insert_delayed main.information_schema \
			main.mysqld--help-notwin main.flush_read_lock_kill \
			sys_vars.plugin_dir_basic main.openssl_1 mysql_tzinfo_to_sql_symlink ; do
				mysql-v2_disable_test  "$t" "False positives in Gentoo"
		done

		# Run mysql tests
		pushd "${TESTDIR}"

		# run mysql-test tests
		perl mysql-test-run.pl --force --vardir="${S}/mysql-test/var-tests" \
			--testcase-timeout=30
		retstatus_tests=$?
		[[ $retstatus_tests -eq 0 ]] || eerror "tests failed"
		has usersandbox $FEATURES && eerror "Some tests may fail with FEATURES=usersandbox"

		popd

		# Cleanup is important for these testcases.
		pkill -9 -f "${S}/ndb" 2>/dev/null
		pkill -9 -f "${S}/sql" 2>/dev/null

		failures=""
		[[ $retstatus_unit -eq 0 ]] || failures="${failures} test-unit"
		[[ $retstatus_tests -eq 0 ]] || failures="${failures} tests"
		has usersandbox $FEATURES && eerror "Some tests may fail with FEATURES=usersandbox"

		[[ -z "$failures" ]] || die "Test failures: $failures"
		einfo "Tests successfully completed"

	else

		einfo "Skipping server tests due to minimal build."
	fi
}
