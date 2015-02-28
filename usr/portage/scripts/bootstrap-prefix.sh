#!/usr/bin/env bash
# Copyright 2006-2014 Gentoo Foundation; Distributed under the GPL v2
# $Id: bootstrap-prefix.sh 61818 2014-01-08 07:28:16Z haubi $

trap 'exit 1' TERM KILL INT QUIT ABRT

# some basic output functions
eerror() { echo "!!! $*" 1>&2; }
einfo() { echo "* $*"; }

# prefer gtar over tar
[[ x$(type -t gtar) == "xfile" ]] \
	&& TAR="gtar" \
	|| TAR="tar"

## Functions Start Here

econf() {
	${CONFIG_SHELL} ./configure \
		--host=${CHOST} \
		--prefix="${ROOT}"/usr \
		--mandir="${ROOT}"/usr/share/man \
		--infodir="${ROOT}"/usr/share/info \
		--datadir="${ROOT}"/usr/share \
		--sysconfdir="${ROOT}"/etc \
		--localstatedir="${ROOT}"/var/lib \
		--build=${CHOST} \
		"$@" || return 1
}

efetch() {
	if [[ ! -e ${DISTDIR}/${1##*/} ]] ; then
	  	if [[ ${OFFLINE_MODE} ]]; then
		  echo "I needed ${1##*/} from $1 or ${GENTOO_MIRRORS}/distfiles/${1##*/} in $DISTDIR"
		  read
		  [[ -e ${DISTDIR}/${1##*/} ]] && return 0
		  #Give fetch a try 
		fi

		if [[ -z ${FETCH_COMMAND} ]] ; then
			# Try to find a download manager, we only deal with wget,
			# curl, FreeBSD's fetch and ftp.
			if [[ x$(type -t wget) == "xfile" ]] ; then
				FETCH_COMMAND="wget"
			elif [[ x$(type -t ftp) == "xfile" ]] ; then
				FETCH_COMMAND="ftp"
			elif [[ x$(type -t curl) == "xfile" ]] ; then
				einfo "WARNING: curl doesn't fail when downloading fails, please check its output carefully!"
				FETCH_COMMAND="curl -L -O"
			elif [[ x$(type -t fetch) == "xfile" ]] ; then
				FETCH_COMMAND="fetch"
			else
				eerror "no suitable download manager found (need wget, curl, fetch or ftp)"
				eerror "could not download ${1##*/}"
				exit 1
			fi
		fi

		mkdir -p "${DISTDIR}" >& /dev/null
		einfo "Fetching ${1##*/}"
		pushd "${DISTDIR}" > /dev/null
		# try for mirrors first, then try given location
		${FETCH_COMMAND} "${GENTOO_MIRRORS}/distfiles/${1##*/}" < /dev/null
		[[ ! -f ${1##*/} && ${1} != ${GENTOO_MIRRORS}/distfiles/${1##*/} ]] \
			&& ${FETCH_COMMAND} "$1" < /dev/null
		if [[ ! -f ${1##*/} ]] ; then
			eerror "downloading ${1} failed!"
			return 1
		fi
		popd > /dev/null
	fi
	return 0
}

# template
# bootstrap_() {
# 	PV=
# 	A=
# 	einfo "Bootstrapping ${A%-*}"

# 	efetch ${A} || return 1

# 	einfo "Unpacking ${A%-*}"
# 	export S="${PORTAGE_TMPDIR}/${PN}"
# 	rm -rf ${S}
# 	mkdir -p ${S}
# 	cd ${S}
# 	$TAR -zxf ${DISTDIR}/${A} || return 1
# 	S=${S}/${PN}-${PV}
# 	cd ${S}

# 	einfo "Compiling ${A%-*}"
# 	econf || return 1
# 	$MAKE ${MAKEOPTS} || return 1

# 	einfo "Installing ${A%-*}"
# 	$MAKE install || return 1

# 	einfo "${A%-*} successfully bootstrapped"
# }

configure_toolchain() {
	export CPPFLAGS="-I${ROOT}/usr/include -I${ROOT}/tmp/usr/include"

	case ${bootstrapCHOST} in
		*-darwin*)
			export LDFLAGS="-Wl,-search_paths_first -L${ROOT}/usr/lib -L${ROOT}/lib -L${ROOT}/tmp/usr/lib"
			;;
		*-solaris* | *-irix*)
			export LDFLAGS="-L${ROOT}/usr/lib -R${ROOT}/usr/lib -L${ROOT}/lib -R${ROOT}/lib -L${ROOT}/tmp/usr/lib -R${ROOT}/tmp/usr/lib"
			;;
		*-hp-hpux*)
			export LDFLAGS="-L${ROOT}/usr/lib -R${ROOT}/usr/lib -L${ROOT}/lib -R${ROOT}/lib -L${ROOT}/tmp/usr/lib -R${ROOT}/tmp/usr/lib -L/usr/local/lib -R/usr/local/lib"
			;;
		*-*-aix*)
			# The bootstrap compiler unlikely has runtime linking
			# enabled already, but elibtoolize switches to the
			# "lib.so(shr.o)" sharedlib variant.
			export LDFLAGS="-Wl,-brtl -L${ROOT}/usr/lib -L${ROOT}/lib -L${ROOT}/tmp/usr/lib"
			;;
		i586-pc-interix* | i586-pc-winnt* | i686-pc-cygwin*)
			export LDFLAGS="-L${ROOT}/usr/lib -L${ROOT}/lib -L${ROOT}/tmp/usr/lib"
			;;
		*)
			export LDFLAGS="-L${ROOT}/usr/lib -Wl,-rpath=${ROOT}/usr/lib -L${ROOT}/lib -Wl,-rpath=${ROOT}/lib -L${ROOT}/tmp/usr/lib -Wl,-rpath=${ROOT}/tmp/usr/lib"
			;;
	esac

	case ${bootstrapCHOST} in
		# note: we need CXX for binutils-apple which' ld is c++
		*64-apple* | sparcv9-*-solaris* | x86_64-*-solaris*)
			[[ -z ${CC} ]] && export CC="gcc -m64"
			[[ -z ${CXX} ]] && export CXX="g++ -m64"
			[[ -z ${HOSTCC} ]] && export HOSTCC="gcc -m64"
			;;
		i*86-apple-darwin1*)
			[[ -z ${CC} ]] && export CC="gcc -m32"
			[[ -z ${CXX} ]] && export CXX="g++ -m32"
			[[ -z ${HOSTCC} ]] && export HOSTCC="gcc -m32"
			;;
		*)
			;;
	esac

	pkggcc="sys-devel/gcc"
	case ${bootstrapCHOST} in
		*-darwin*)
			case "$(gcc --version)" in
				*"(GCC) 4.2.1 "*|*"Apple LLVM version 5."*)
					local linker=sys-devel/binutils-apple
					;;
				*"(GCC) 4.0.1 "*)
					local linker="=sys-devel/binutils-apple-3.2"
					;;
				*)
					eerror "unknown compiler"
					return 1
					;;
			esac
			toolchainpackages=(
				sys-apps/darwin-miscutils
				sys-libs/csu
				${linker}
				sys-devel/gcc-apple
			)
			pkggcc="sys-devel/gcc-apple"
			;;
		i?86-*-solaris*)
			# 4.2/x86 can't cope with Sun ld/as
			# results in a bootstrap compare mismatch

			# Figure out what Solaris we're on.  Since Solaris 10u10
			# some Solaris 11 changes have been integrated that
			# implement some GNU extensions to ELF.  This most notably
			# is the VERSYM_HIDDEN flag, that GCC 4.1 doesn't know
			# about, resulting in a libstdc++.so that cannot find these
			# hidden symbols.  GCC 4.2 knows about these, so we must
			# have it there.  Unfortunately, 4.2 doesn't always compile,
			# so we need to perform the expensive 4.1 -> 4.2 -> current.
			local SOLARIS_RELEASE=$(head -n1 /etc/release)
			local needgcc42=
			case "${SOLARIS_RELEASE}" in
				*"Solaris 10"*)
					# figure out major update level
					SOLARIS_RELEASE=${SOLARIS_RELEASE##*s10s_u}
					SOLARIS_RELEASE=${SOLARIS_RELEASE##*s10x_u}
					SOLARIS_RELEASE=${SOLARIS_RELEASE%%wos_*}
					if [[ "${SOLARIS_RELEASE}" -ge "10" ]] ; then
						needgcc42="=sys-devel/gcc-4.2*"
					fi
					;;
				*)
					# assume all the rest is Oracle Solaris 11,
					# OpenSolaris, OpenIndiana, SmartOS, whatever,
					# thus > Solaris 10u10
					needgcc42="=sys-devel/gcc-4.2*"
					;;
			esac

			toolchainpackages=(
				sys-devel/binutils
				"=sys-devel/gcc-4.1*"
				${needgcc42}
			)
			;;
		sparc-*-solaris2.11)
			# unknown what the problem is here
			toolchainpackages=(
				sys-devel/binutils
				"=sys-devel/gcc-4.1*"
				"=sys-devel/gcc-4.2*"
			)
			;;
		*-*-aix*)
			toolchainpackages=(
				sys-apps/diffutils # or gcc PR14251
				sys-devel/native-cctools
				"=sys-devel/gcc-4.2*"
				sys-apps/aix-miscutils
				sys-apps/texinfo
			)
			;;
		*)
			toolchainpackages=(
				sys-devel/binutils
				"=sys-devel/gcc-4.2*"
			)
			;;
	esac
}

bootstrap_setup() {
	local profile=""
	einfo "setting up some guessed defaults"
	case ${CHOST} in
		powerpc-apple-darwin7)
			profile="prefix/darwin/macos/10.3"
			;;
		powerpc-apple-darwin[89])
			rev=${CHOST##*darwin}
			profile="prefix/darwin/macos/10.$((rev - 4))/ppc"
			;;
		powerpc64-apple-darwin[89])
			rev=${CHOST##*darwin}
			profile="prefix/darwin/macos/10.$((rev - 4))/ppc64"
			;;
		i*86-apple-darwin[89])
			rev=${CHOST##*darwin}
			profile="prefix/darwin/macos/10.$((rev - 4))/x86"
			;;
		i*86-apple-darwin1[0123])
			rev=${CHOST##*darwin}
			profile="prefix/darwin/macos/10.$((rev - 4))/x86"
			;;
		x86_64-apple-darwin9|x86_64-apple-darwin1[0123])
			rev=${CHOST##*darwin}
			profile="prefix/darwin/macos/10.$((rev - 4))/x64"
			;;
		i*86-pc-linux-gnu)
			profile="prefix/linux/x86"
			;;
		x86_64-pc-linux-gnu)
			profile="prefix/linux/amd64"
			;;
		ia64-pc-linux-gnu)
			profile="prefix/linux/ia64"
			;;
		powerpc-unknown-linux-gnu)
			profile="prefix/linux/ppc"
			;;
		powerpc64-unknown-linux-gnu)
			profile="prefix/linux/ppc64"
			;;
		armv7l-pc-linux-gnu)
			profile="prefix/linux/arm"
			;;
		sparc-sun-solaris2.9)
			profile="prefix/sunos/solaris/5.9/sparc"
			;;
		sparcv9-sun-solaris2.9)
			profile="prefix/sunos/solaris/5.9/sparc64"
			# we need this, or binutils can't link, can't add it to -L,
			# since then binutils breaks on finding an old libiberty.a
			# from there instead of its own
			cp /usr/sfw/lib/64/libgcc_s.so.1 "${ROOT}"/tmp/usr/lib/
			;;
		i386-pc-solaris2.10)
			profile="prefix/sunos/solaris/5.10/x86"
			;;
		x86_64-pc-solaris2.10)
			profile="prefix/sunos/solaris/5.10/x64"
			# we need this, or binutils can't link, can't add it to -L,
			# since then binutils breaks on finding an old libiberty.a
			# from there instead of its own
			cp /usr/sfw/lib/64/libgcc_s.so.1 "${ROOT}"/tmp/usr/lib/
			;;
		sparc-sun-solaris2.10)
			profile="prefix/sunos/solaris/5.10/sparc"
			;;
		sparcv9-sun-solaris2.10)
			profile="prefix/sunos/solaris/5.10/sparc64"
			# we need this, or binutils can't link, can't add it to -L,
			# since then binutils breaks on finding an old libiberty.a
			# from there instead of its own
			cp /usr/sfw/lib/64/libgcc_s.so.1 "${ROOT}"/tmp/usr/lib/
			;;
		i386-pc-solaris2.11)
			profile="prefix/sunos/solaris/5.11/x86"
			;;
		x86_64-pc-solaris2.11)
			profile="prefix/sunos/solaris/5.11/x64"
			# we need this, or binutils can't link, can't add it to -L,
			# since then binutils breaks on finding an old libiberty.a
			# from there instead of its own
			cp /usr/sfw/lib/64/libgcc_s.so.1 "${ROOT}"/tmp/usr/lib/
			;;
		sparc-sun-solaris2.11)
			profile="prefix/sunos/solaris/5.11/sparc"
			;;
		sparcv9-sun-solaris2.11)
			profile="prefix/sunos/solaris/5.11/sparc64"
			# we need this, or binutils can't link, can't add it to -L,
			# since then binutils breaks on finding an old libiberty.a
			# from there instead of its own
			cp /usr/sfw/lib/64/libgcc_s.so.1 "${ROOT}"/tmp/usr/lib/
			;;
		powerpc-ibm-aix*)
			profile="prefix/aix/${CHOST#powerpc-ibm-aix}/ppc"
			;;
		mips-sgi-irix*)
			profile="prefix/irix/${CHOST#mips-sgi-irix}/mips"
			;;
		i586-pc-interix*)
			profile="prefix/windows/interix/${CHOST#i586-pc-interix}/x86"
			;;
		i586-pc-winnt*)
			profile="prefix/windows/winnt/${CHOST#i586-pc-winnt}/x86"
			;;
		i686-pc-cygwin*)
			profile="prefix/windows/cygwin/${CHOST#i686-pc-cygwin}/x86"
			;;
		hppa64*-hp-hpux11*)
			profile="prefix/hpux/B.11${CHOST#hppa*-hpux11}/hppa64"
			;;
		hppa2.0*-hp-hpux11*)
			profile="prefix/hpux/B.11${CHOST#hppa*-hpux11}/hppa2.0"
			;;
		ia64-hp-hpux11*)
			profile="prefix/hpux/B.11${CHOST#ia64-hp-hpux11}/ia64"
			;;
		i386-pc-freebsd*)
			profile="prefix/bsd/freebsd/${CHOST#i386-pc-freebsd}/x86"
			;;
		x86_64-pc-freebsd*)
			profile="prefix/bsd/freebsd/${CHOST#x86_64-pc-freebsd}/x64"
			;;
		i386-pc-netbsd*)
			profile="prefix/bsd/netbsd/${CHOST#i386-pc-netbsdelf}/x86"
			;;
		powerpc-unknown-openbsd*)
			profile="prefix/bsd/openbsd/${CHOST#powerpc-unknown-openbsd}/ppc"
			;;
		i386-pc-openbsd*)
			profile="prefix/bsd/openbsd/${CHOST#i386-pc-openbsd}/x86"
			;;
		x86_64-pc-openbsd*)
			profile="prefix/bsd/openbsd/${CHOST#x86_64-pc-openbsd}/x64"
			;;
		*)	
			einfo "UNKNOWN ARCH: You need to set up a make.profile symlink to a"
			einfo "profile in ${PORTDIR} for your CHOST ${CHOST}"
			;;
	esac
	if [[ -n ${profile} && ! -e ${ROOT}/etc/portage/make.profile ]] ; then
		local fullprofile="${PORTDIR}/profiles/${profile}"
		for base in ${PORTDIR_OVERLAY} ; do
			if [[ -e ${base}/profiles/${profile}/parent ]] ; then
				fullprofile="${base}/profiles/${profile}"
				break
			fi
		done
		
		ln -s "${fullprofile}" "${ROOT}"/etc/portage/make.profile
		einfo "Your profile is set to ${fullprofile}."
	fi
	
	# Disable the STALE warning because the snapshot frequently gets stale.
	echo 'PORTAGE_SYNC_STALE=0 # for bootstrap-prefix.sh' >> "${ROOT}"/etc/portage/make.profile/make.defaults
	
	# Some people will hit bug 262653 with gcc-4.2 and elfutils. Let's skip it
	# here and bring it in AFTER the --sync
	echo "dev-libs/elfutils-0.153 # for bootstrap-prefix.sh" >> "${ROOT}"/etc/portage/make.profile/package.provided
}

do_tree() {
	local x
	for x in etc{,/portage} usr/{{,s}bin,lib} var/tmp var/lib/portage var/log/portage var/db;
	do
		[[ -d ${ROOT}/${x} ]] || mkdir -p "${ROOT}/${x}"
	done
	if [[ ${PREFIX_DISABLE_USR_SPLIT} == "yes" ]] ; then
		# note to self: don't make bin a symlink to usr/bin for
		# coreutils installs symlinks to from usr/bin to bin, which in
		# case they are the same boils down to a pointless indirection
		# to self
		for x in lib sbin ; do
			[[ -e ${ROOT}/${x} ]] || ( cd "${ROOT}" && ln -s usr/${x} )
		done
	else
		for x in lib sbin ; do
			[[ -d ${ROOT}/${x} ]] || mkdir -p "${ROOT}/${x}"
		done
	fi
	if [[ ! -e ${PORTDIR}/.unpacked ]]; then
		efetch "$1/$2" || return 1
		[[ -e ${PORTDIR} ]] || mkdir -p ${PORTDIR}
		einfo "Unpacking, this may take a while"
		bzip2 -dc ${DISTDIR}/$2 | $TAR -xf - -C ${PORTDIR} --strip-components=1 || return 1
		touch ${PORTDIR}/.unpacked
	fi
}

bootstrap_tree() {
	local PV="20140812"
	if [[ -n ${LATEST_TREE_YES} ]]; then
		do_tree "${SNAPSHOT_URL}" portage-latest.tar.bz2
	else
		do_tree http://prefix.gentooexperimental.org/distfiles prefix-overlay-${PV}.tar.bz2
	fi
}

bootstrap_latest_tree() {
	# kept here for compatibility reasons
	einfo "This function 'latest_tree' is deprecated and will be"
	einfo "removed in the future, please set LATEST_TREE_YES=1 in the env"
	LATEST_TREE_YES=1 bootstrap_tree
}

bootstrap_startscript() {
	local theshell=${SHELL##*/}
	if [[ ${theshell} == "sh" ]] ; then
		einfo "sh is a generic shell, using bash instead"
		theshell="bash"
	fi
	if [[ ${theshell} == "csh" ]] ; then
		einfo "csh is a prehistoric shell not available in Gentoo, switching to tcsh instead"
		theshell="tcsh"
	fi
	einfo "Trying to emerge the shell you use, if necessary by running:"
	einfo "emerge -u ${theshell}"
	if ! emerge -u ${theshell} ; then
		eerror "Your shell is not available in portage, hence we cannot" > /dev/stderr
		eerror "automate starting your prefix, set SHELL and rerun this script" > /dev/stderr
		return 1
	fi
	einfo "Creating the Prefix start script (startprefix)"
	# currently I think right into the prefix is the best location, as
	# putting it in /bin or /usr/bin just hides it some more for the
	# user
	sed \
		-e "s|@GENTOO_PORTAGE_EPREFIX@|${ROOT}|g" \
		"${ROOT}"/usr/portage/scripts/startprefix.in \
		> "${ROOT}"/startprefix
	chmod 755 "${ROOT}"/startprefix
	einfo "To start Gentoo Prefix, run the script ${ROOT}/startprefix"
	einfo "You can copy this file to a more convenient place if you like."

	# see if PATH is kept/respected
	local minPATH="preamble:${BASH%/*}:postlude"
	local theirPATH="$(echo 'echo "${PATH}"' | env LS_COLORS= PATH="${minPATH}" $SHELL -l 2>/dev/null | grep "preamble:.*:postlude")"
	if [[ ${theirPATH} != *"preamble:"*":postlude"* ]] ; then
		einfo "WARNING: your shell initialisation (.cshrc, .bashrc, .profile)"
		einfo "         seems to overwrite your PATH, this effectively kills"
		einfo "         your Prefix.  Change this to only append to your PATH"
	elif [[ ${theirPATH} != "preamble:"* ]] ; then
		einfo "WARNING: your shell initialisation (.cshrc, .bashrc, .profile)"
		einfo "         seems to prepend to your PATH, this might kill your"
		einfo "         Prefix:"
		einfo "         ${theirPATH%%preamble:*}"
		einfo "         You better fix this, YOU HAVE BEEN WARNED!"
	fi
}

bootstrap_portage() {
	# Set TESTING_PV in env if you want to test a new portage before bumping the
	# STABLE_PV that is known to work. Intended for power users only.
	## It is critical that STABLE_PV is the lastest (non-masked) version that is
	## included in the snapshot for bootstrap_tree.
	STABLE_PV="2.2.8"
	[[ ${TESTING_PV} == latest ]] && TESTING_PV="2.2.8"
	PV="${TESTING_PV:-${STABLE_PV}}"
	A=prefix-portage-${PV}.tar.bz2
	einfo "Bootstrapping ${A%-*}"
		
	efetch ${DISTFILES_URL}/${A} || return 1

	einfo "Unpacking ${A%-*}"
	export S="${PORTAGE_TMPDIR}"/portage-${PV}
	ptmp=${S}
	rm -rf "${S}" >& /dev/null
	mkdir -p "${S}" >& /dev/null
	cd "${S}"
	bzip2 -dc "${DISTDIR}/${A}" | $TAR -xf - || return 1
	S="${S}/prefix-portage-${PV}"
	cd "${S}"

	# disable ipc
	sed -e "s:_enable_ipc_daemon = True:_enable_ipc_daemon = False:" \
		-i pym/_emerge/AbstractEbuildProcess.py || \
		return 1

	# Portage checks for valid shebangs. These may (xz-utils) originate
	# in CONFIG_SHELL (AIX), which originates in PORTAGE_BASH then.
	# So we need to ensure portage's bash is valid as shebang too.
	mkdir -p ${ROOT}/bin || return 1
	[[ -x ${ROOT}/bin/bash ]] || [[ ! -x ${ROOT}/tmp/usr/bin/bash ]] || ln -s ${ROOT}/tmp/usr/bin/bash ${ROOT}/bin/bash || return 1
	[[ -x ${ROOT}/bin/bash ]] || ln -s ${BASH} ${ROOT}/bin/bash || return 1
	export PORTAGE_BASH=${ROOT}/bin/bash

	einfo "Compiling ${A%-*}"
	econf \
		--with-offset-prefix="${ROOT}" \
		--with-portage-user="`id -un`" \
		--with-portage-group="`id -gn`" \
		--mandir="${ROOT}/automatically-removed" \
		--with-extra-path="${ROOT}/tmp/usr/bin:/bin:/usr/bin:${PATH}" \
		|| return 1
	$MAKE ${MAKEOPTS} || return 1

 	einfo "Installing ${A%-*}"
	$MAKE install || return 1

	bootstrap_setup

	cd "${ROOT}"
	rm -Rf ${ptmp} >& /dev/null

	# Some people will skip the tree() step and hence var/log is not created 
	# As such, portage complains..
	[[ ! -d $ROOT/var/log ]] && mkdir ${ROOT}/var/log
	
	# during bootstrap_portage(), man pages are not compressed. This is
	# problematic once you have a working prefix. So, remove them now.
	rm -rf "${ROOT}/automatically-removed"	

	# in Prefix the sed wrapper is deadly, so kill it
	rm -f "${ROOT}"/usr/lib/portage/bin/ebuild-helpers/sed

	einfo "${A%-*} successfully bootstrapped"
}

prep_gcc-apple() {

	GCC_PV=5341
	GCC_A="gcc-${GCC_PV}.tar.gz"
	TAROPTS="-zxf"

	efetch ${GCC_APPLE_URL}/${GCC_A} || return 1

}

prep_gcc-fsf() {

	GCC_PV=4.1.2
	GCC_A=gcc-${GCC_PV}.tar.bz2	
	TAROPTS="-jxf"

	efetch ${GENTOO_MIRRORS}/distfiles/${GCC_A} || return 1

}

bootstrap_gcc() {

	case ${CHOST} in
		*-*-darwin*)
			prep_gcc-apple
			;;
		*-*-solaris*)
			prep_gcc-fsf
			GCC_EXTRA_OPTS="--disable-multilib --with-gnu-ld"
			;;
		*)	
			prep_gcc-fsf
			;;
	esac

	GCC_LANG="c,c++"

	export S="${PORTAGE_TMPDIR}/gcc-${GCC_PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	einfo "Unpacking ${GCC_A}"
	$TAR ${TAROPTS} "${DISTDIR}"/${GCC_A} || return 1

	rm -rf "${S}"/build
	mkdir -p "${S}"/build
	cd "${S}"/build

	${CONFIG_SHELL} ${S}/gcc-${GCC_PV}/configure \
		--prefix="${ROOT}"/usr \
		--mandir="${ROOT}"/usr/share/man \
		--infodir="${ROOT}"/usr/share/info \
		--datadir="${ROOT}"/usr/share \
		--disable-checking \
		--disable-werror \
		--disable-nls \
		--with-system-zlib \
		--enable-languages=${GCC_LANG} \
		${GCC_EXTRA_OPTS} \
		|| return 1

	$MAKE ${MAKEOPTS} bootstrap-lean || return 1

	$MAKE install || return 1

	cd "${ROOT}"
	rm -Rf "${S}"
	einfo "${GCC_A%-*} successfully bootstrapped"
}

bootstrap_gnu() {
	local PN PV A S
	PN=$1
	PV=$2

	einfo "Bootstrapping ${PN}"

	for t in tar.gz tar.xz tar.bz2 tar ; do
		A=${PN}-${PV}.${t}

		# save the user some useless downloading
		if [[ ${t} == tar.gz ]] ; then
			type -P gzip > /dev/null || continue
		fi
		if [[ ${t} == tar.xz ]] ; then
			type -P xz > /dev/null || continue
		fi
		if [[ ${t} == tar.bz2 ]] ; then
			type -P bzip2 > /dev/null || continue
		fi

		URL=${GNU_URL}/${PN}/${A}
		efetch ${URL} || continue

		einfo "Unpacking ${A%-*}"
		S="${PORTAGE_TMPDIR}/${PN}-${PV}"
		rm -rf "${S}"
		mkdir -p "${S}"
		cd "${S}"
		if [[ ${t} == "tar.gz" ]] ; then
			gzip -dc "${DISTDIR}"/${URL##*/} | $TAR -xf - || continue
		elif [[ ${t} == "tar.xz" ]] ; then
			xz -dc "${DISTDIR}"/${URL##*/} | $TAR -xf - || continue
		elif [[ ${t} == "tar.bz2" ]] ; then
			bzip2 -dc "${DISTDIR}"/${URL##*/} | $TAR -xf - || continue
		elif [[ ${t} == "tar" ]] ; then
			$TAR -xf "${DISTDIR}"/${A} || continue
		else
			einfo "unhandled extension: $t"
			return 1
		fi
		break
	done
	S="${S}"/${PN}-${PV}
	[[ -d ${S} ]] || return 1
	cd "${S}" || return 1

	local myconf=""
	if [[ ${PN} == "grep" ]] ; then
		# Solaris and OSX don't like it when --disable-nls is set,
		# so just don't set it at all.
		# Solaris 11 has a messed up prce installation.  We don't need
		# it anyway, so just disable it
		myconf="${myconf} --disable-perl-regexp"
		# Except interix really needs it for grep.
		[[ $CHOST == *interix* ]] && myconf="${myconf} --disable-nls"
	fi

	# AIX doesn't like --enable-nls in general during bootstrap
	[[ $CHOST == *-aix* ]] && myconf="${myconf} --disable-nls"
	# AIX 7.1 has fstatat(), but broken without APAR IV23716:
	[[ $CHOST == *-aix7* ]] && export ac_cv_func_fstatat=no
	# AIX lacks /dev/fd/*, bash uses (blocking) named pipes instead
	[[ ${PN} == "bash" ]] && sed -i -e 's/|O_NONBLOCK//' subst.c

	# NetBSD has strange openssl headers, which make wget fail.
	[[ $CHOST == *-netbsd* ]] && myconf="${myconf} --disable-ntlm"

	# Darwin9 in particular doesn't compile when using system readline,
	# but we don't need any groovy input at all, so just disable it
	[[ ${PN} == "bash" ]] && myconf="${myconf} --disable-readline"

	# Don't do ACL stuff on Darwin, especially Darwin9 will make
	# coreutils completely useless (install failing on everything)
	# Don't try using gmp either, it may be that just the library is
	# there, and if so, the buildsystem assumes the header exists too
	[[ ${PN} == "coreutils" ]] && \
		myconf="${myconf} --disable-acl --without-gmp"

	if [[ ${PN} == "coreutils" && ${CHOST} == *-interix* ]] ; then
		# Interix doesn't have filesystem listing stuff, but that means all
		# other utilities but df aren't useless at all, so don't die
		sed -i -e '/^if test -z "$ac_list_mounted_fs"; then$/c\if test 1 = 0; then' configure

		# try to make id() not poll the entire domain before returning
		export CFLAGS="${CFLAGS} -Dgetgrgid=getgrgid_nomembers -Dgetgrent=getgrent_nomembers -Dgetgrnam=getgrnam_nomembers"

		# Fix a compilation error due to a missing definition
		sed -i -e '/^#include "fcntl-safer.h"$/a\#define ESTALE -1' lib/savewd.c
	fi

	if [[ ${PN} == "tar" && ${CHOST} == *-hpux* ]] ; then
		# Fix a compilation error due to a missing definition
		export CPPFLAGS="${CPPFLAGS} -DCHAR_BIT=8"
	fi

	# Gentoo Bug 400831, fails on Ubuntu with libssl-dev installed
	[[ ${PN} == "wget" ]] && myconf="${myconf} --without-ssl"

	einfo "Compiling ${PN}"
	econf ${myconf} || return 1
	if [[ ${PN} == "make" && $(type -t $MAKE) != "file" ]]; then
		./build.sh || return 1
	else
		$MAKE ${MAKEOPTS} || return 1
	fi

	einfo "Installing ${PN}"
	if [[ ${PN} == "make" && $(type -t $MAKE) != "file" ]]; then
		./make install MAKE="${S}/make" || return 1
	else
		$MAKE install || return 1
	fi

	cd "${ROOT}"
	rm -Rf "${S}"
	einfo "${PN}-${PV} successfully bootstrapped"
}

bootstrap_python() {
	PV=2.7.3

	case $CHOST in
		*-*-aix*)
			# TODO: freebsd 10 also seems to need this
			A=Python-${PV}.tar.bz2 # patched one breaks
			patch=true
		;;
		*)
			A=python-${PV}-patched.tar.bz2
			patch=false
		;;
	esac

	einfo "Bootstrapping ${A%-*}"

	# don't really want to put this on the mirror, since they are
	# non-vanilla sources, bit specific for us
	efetch ${DISTFILES_URL}/${A} || return 1

	einfo "Unpacking ${A%%-*}"
	export S="${PORTAGE_TMPDIR}/python-${PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	bzip2 -dc "${DISTDIR}"/${A} | $TAR -xf - || return 1
	S="${S}"/Python-${PV}
	cd "${S}"

	if ${patch}; then
		# This patch is critical and needs to be applied even
		# when using the otherwise unpatched sources.
		efetch "http://dev.gentoo.org/~redlizard/distfiles/02_all_disable_modules_and_ssl.patch"
		patch -p0 < "${DISTDIR}"/02_all_disable_modules_and_ssl.patch
	fi

	local myconf=""

	case $CHOST in
	(x86_64-*-*|sparcv9-*-*)
		export CFLAGS="-m64"
		;;
	(i?86-*-*)
		export CFLAGS="-m32"
		;;
	esac

	case $CHOST in
		*-*-aix*)
			# Python stubbornly insists on using cc_r to compile.  We
			# know better, so force it to listen to us
			myconf="${myconf} --with-gcc=yes"
		;;
		*-openbsd*)
			CFLAGS="${CFLAGS} -D_BSD_SOURCE=1"
		;;
		*-linux*)
			# Bug 382263: make sure Python will know about the libdir in use for
			# the current arch
			libdir="-L/usr/lib/$(gcc ${CFLAGS} -print-multi-os-directory)"
		;;
		x86_64-*-solaris*|sparcv9-*-solaris*)
			# Like above, make Python know where GCC's 64-bits
			# libgcc_s.so is on Solaris
			libdir="-L/usr/sfw/lib/64"
		;;
	esac

	# python refuses to find the zlib headers that are built in the
	# offset
	export CPPFLAGS="-I$EPREFIX/tmp/usr/include"
	export LDFLAGS="${CFLAGS} -L$EPREFIX/tmp/usr/lib"
	# set correct flags for runtime for ELF platforms
	case $CHOST in
		*-*bsd*|*-linux*)
			# GNU ld
			export LDFLAGS="${LDFLAGS} -Wl,-rpath,$EPREFIX/tmp/usr/lib ${libdir}"
		;;
		*-solaris*)
			# Sun ld
			export LDFLAGS="${LDFLAGS} -R$EPREFIX/tmp/usr/lib ${libdir}"
		;;
	esac

	# if the user has a $HOME/.pydistutils.cfg file, the python
	# installation is going to be screwed up, as reported by users, so
	# just make sure Python won't find it
	export HOME="${S}"

	export PYTHON_DISABLE_MODULES="_bsddb bsddb bsddb185 bz2 crypt _ctypes_test _curses _curses_panel dbm _elementtree gdbm _locale nis pyexpat readline _sqlite3 _tkinter"
	export PYTHON_DISABLE_SSL=1
	export OPT="${CFLAGS}"

	einfo "Compiling ${A%-*}"

	#some ancient versions of hg fail with "hg id -i", so help configure to not find them
	HAS_HG=no \
	econf \
		--disable-toolbox-glue \
		--disable-ipv6 \
		--disable-shared \
		${myconf} || return 1
	$MAKE ${MAKEOPTS} || return 1

	einfo "Installing ${A%-*}"
	$MAKE -k install || echo "??? Python failed to install *sigh* continuing anyway"
	cd "${ROOT}"/usr/bin
	ln -sf python${PV%.*} python
	cd "${ROOT}"/usr/lib
	# messes up python emerges, and shouldn't be necessary for anything
	# http://forums.gentoo.org/viewtopic-p-6890526.html
	rm -f libpython${PV%.*}.a

	einfo "${A%-*} bootstrapped"
}

bootstrap_zlib_core() {
	# use 1.2.5 by default, current bootstrap guides
	PV="${1:-1.2.5}"
	A=zlib-${PV}.tar.gz

	einfo "Bootstrapping ${A%-*}"

	if ! efetch ${GENTOO_MIRRORS}/distfiles/${A} ; then
		A=zlib-${PV}.tar.bz2
		efetch ${GENTOO_MIRRORS}/distfiles/${A} || return 1
	fi

	einfo "Unpacking ${A%%-*}"
	export S="${PORTAGE_TMPDIR}/zlib-${PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	if [[ ${A} == *.tar.gz ]] ; then
		gzip -dc "${DISTDIR}"/${A} | $TAR -xf - || return 1
	else
		bzip2 -dc "${DISTDIR}"/${A} | $TAR -xf - || return 1
	fi
	S="${S}"/zlib-${PV}
	cd "${S}"

	if [[ ${CHOST} == x86_64-*-* || ${CHOST} == sparcv9-*-* ]] ; then
		# 64-bits targets need zlib as library (not just to unpack),
		# hence we need to make sure that we really bootstrap this
		# 64-bits (in contrast to the tools which we don't care if they
		# are 32-bits)
		export CC="gcc -m64"
	elif [[ ${CHOST} == i?86-*-* ]] ; then
		# This is important for bootstraps which are 64-native, but we
		# want 32-bits, such as most Linuxes, and more recent OSX.
		# OS X Lion and up default to a 64-bits userland, so force the
		# compiler to 32-bits code generation if requested here
		export CC="gcc -m32"
	fi
	# 1.2.5 suffers from a concurrency problem
	[[ ${PV} == 1.2.5 ]] && MAKEOPTS=

	einfo "Compiling ${A%-*}"
	CHOST= ${CONFIG_SHELL} ./configure --prefix="${ROOT}"/usr || return 1
	$MAKE ${MAKEOPTS} || return 1

	einfo "Installing ${A%-*}"
	$MAKE install || return 1

	# this lib causes issues when emerging python again on Solaris
	# because the tmp lib path is in the library search path there
	rm -Rf "${ROOT}"/usr/lib/libz*.a

	if [[ ${CHOST} == *-aix* ]]; then
		# No aix-soname support, but symlinks when built with gcc. This breaks
		# later on when aix-soname is added within Prefix, where the lib.so.1
		# is an archive then, while finding this one first due to possible
		# rpath ordering issues.
		rm -f "${ROOT}"/usr/lib/libz.so.1
	fi

	einfo "${A%-*} bootstrapped"
}

bootstrap_zlib() {
	bootstrap_zlib_core 1.2.8 || bootstrap_zlib_core 1.2.7 || \
	bootstrap_zlib_core 1.2.6 || bootstrap_zlib_core 1.2.5
}

bootstrap_sed() {
	bootstrap_gnu sed 4.2.1
}

bootstrap_findutils() {
	bootstrap_gnu findutils 4.5.10 || bootstrap_gnu findutils 4.2.33
}

bootstrap_wget() {
	bootstrap_gnu wget 1.13.4
}

bootstrap_grep() {
	# don't use 2.13, it contains a bug that bites, bug #425668
	# 2.9 is the last version provided as tar.gz (platforms without xz)
	# 2.7 is necessary for Solaris/OpenIndiana (2.8, 2.9 fail to configure)
	bootstrap_gnu grep 2.14 || bootstrap_gnu grep 2.12 || \
		bootstrap_gnu grep 2.9 || bootstrap_gnu grep 2.7
}

bootstrap_coreutils() {
	# 8.12 for FreeBSD 9.1, bug #415439
	# 8.16 is the last version released as tar.gz
	bootstrap_gnu coreutils 8.17 || bootstrap_gnu coreutils 8.16 || \
	bootstrap_gnu coreutils 8.12 
}

bootstrap_tar() {
	bootstrap_gnu tar 1.26
}

bootstrap_make() {
	MAKEOPTS= # no GNU make yet
	bootstrap_gnu make 3.82
}

bootstrap_patch() {
	# 2.5.9 needed for OSX 10.6.x
	bootstrap_gnu patch 2.6.1 || bootstrap_gnu patch 2.5.9 || \
		bootstrap_gnu patch 2.5.4
}

bootstrap_gawk() {
	bootstrap_gnu gawk 4.0.1 || bootstrap_gnu gawk 4.0.0 || \
		bootstrap_gnu gawk 3.1.8
}

bootstrap_binutils() {
	bootstrap_gnu binutils 2.17
}

bootstrap_texinfo() {
	bootstrap_gnu texinfo 4.8
}

bootstrap_bash() {
	bootstrap_gnu bash 4.2
}

bootstrap_bison() {
	bootstrap_gnu bison 2.6.2 || bootstrap_gnu bison 2.6.1 || \
		bootstrap_gnu bison 2.6 || bootstrap_gnu bison 2.5.1 || \
		bootstrap_gnu bison 2.4
}

bootstrap_m4() {
	bootstrap_gnu m4 1.4.17 || bootstrap_gnu m4 1.4.16 || bootstrap_gnu m4 1.4.15
}

bootstrap_gzip() {
	bootstrap_gnu gzip 1.4
}

bootstrap_bzip2() {
	local PN PV A S
	PN=bzip2
	PV=1.0.6
	A=${PN}-${PV}.tar.gz
	einfo "Bootstrapping ${A%-*}"

	efetch ${GENTOO_MIRRORS}/distfiles/${A} || return 1

	einfo "Unpacking ${A%-*}"
	S="${PORTAGE_TMPDIR}/${PN}-${PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	gzip -dc "${DISTDIR}"/${A} | $TAR -xf - || return 1
	S="${S}"/${PN}-${PV}
	cd "${S}"

	einfo "Compiling ${A%-*}"
	$MAKE || return 1

	einfo "Installing ${A%-*}"
	$MAKE PREFIX="${ROOT}"/usr install || return 1

	cd "${ROOT}"
	rm -Rf "${S}"
	einfo "${A%-*} successfully bootstrapped"
}

bootstrap_stage1() {
	if [[ ${ROOT} != */tmp ]] ; then
		eerror "stage1 can only be used for paths that end in '/tmp'"
		return 1
	fi

	# NOTE: stage1 compiles all tools (no libraries) in the native
	# bits-size of the compiler, which needs not to match what we're
	# bootstrapping for.  This is no problem since they're just tools,
	# for which it really doesn't matter how they run, as long AS they
	# run.  For libraries, this is different, since they are relied on
	# by packages we emerge lateron.
	# Changing this to compile the tools for the bits the bootstrap is
	# for, is a BAD idea, since we're extremely fragile here, so
	# whatever the native toolchain is here, is what in general works
	# best.

	# run all bootstrap_* commands in a subshell since the targets
	# frequently pollute the environment using exports which affect
	# packages following (e.g. zlib builds 64-bits)

	# don't rely on $MAKE, if make == gmake packages that call 'make' fail
	[[ $(make --version 2>&1) == *GNU* ]] || (bootstrap_make) || return 1
	[[ ${OFFLINE_MODE} ]] || type -P wget > /dev/null || (bootstrap_wget) || return 1
	[[ $(sed --version 2>&1) == *GNU* ]] || (bootstrap_sed) || return 1
	[[ $(m4 --version 2>&1) == *GNU*1.4.1?* ]] || (bootstrap_m4) || return 1
	[[ $(bison --version 2>&1) == *"(GNU Bison) 2."[345678]* ]] \
		|| [[ -x ${ROOT}/usr/bin/bison ]] \
		|| (bootstrap_bison) || return 1
	[[ $(uniq --version 2>&1) == *"(GNU coreutils) "[6789]* ]] \
		|| (bootstrap_coreutils) || return 1
	[[ $(find --version 2>&1) == *GNU* ]] || (bootstrap_findutils) || return 1
	[[ $(tar --version 2>&1) == *GNU* ]] || (bootstrap_tar) || return 1
	[[ $(patch --version 2>&1) == *GNU* ]] || (bootstrap_patch) || return 1
	[[ $(grep --version 2>&1) == *GNU* ]] || (bootstrap_grep) || return 1
	[[ $(awk --version < /dev/null 2>&1) == *GNU* ]] || bootstrap_gawk || return 1
	[[ $(bash --version 2>&1) == "GNU bash, version 4."[123456789]* && ${CHOST} != *-aix* ]] \
		|| [[ -x ${ROOT}/usr/bin/bash ]] \
		|| (bootstrap_bash) || return 1
	if type -P pkg-config > /dev/null ; then
		# it IS possible to get here without installing anything in
		# tmp/usr/bin, which makes the below fail to happen
		mkdir -p "${ROOT}"/usr/bin/
		# hide an existing pkg-config for glib, which first checks
		# pkg-config for libffi, and only then the LIBFFI_* vars
		# this resolves nasty problems like bug #426302
		# note that an existing pkg-config can be ancient, which glib
		# doesn't grok (e.g. Solaris 10) => error
		{
			echo "#!/bin/sh"
			echo "exit 1"
		} > "${ROOT}"/usr/bin/pkg-config
		chmod 755 "${ROOT}"/usr/bin/pkg-config
	fi
	type -P bzip2 > /dev/null || (bootstrap_bzip2) || return 1
	# important to have our own (non-flawed one) since Python (from
	# Portage) and binutils use it
	for zlib in ${ROOT}/usr/lib/libz.* ; do
		[[ -e ${zlib} ]] && break
		zlib=
	done
	[[ -n ${zlib} ]] || (bootstrap_zlib) || return 1
	# too vital to rely on a host-provided one
	[[ -x ${ROOT}/usr/bin/python ]] || (bootstrap_python) || return 1

	einfo "stage1 successfully finished"
}

bootstrap_stage2() {
	if [[ ${ROOT} == */tmp ]] ; then
		eerror "stage2 cannot be used for paths that end in '/tmp'"
		return 1
	fi

	# checks itself if things need to be done still
	bootstrap_tree || return 1

	# try to keep distfiles, we might be able to reuse them
	[[ -d ${ROOT}/usr/portage/distfiles ]] || \
		mv "${ROOT}"/tmp/usr/portage/distfiles "${ROOT}"/usr/portage/

	# setup portage
	[[ -e ${ROOT}/etc/make.globals ]] || bootstrap_portage || return 1

	einfo "stage2 successfully finished"
}

bootstrap_stage3() {
	if [[ ${ROOT} == */tmp ]] ; then
		eerror "stage3 cannot be used for paths that end in '/tmp'"
		return 1
	fi

	if ! type -P emerge > /dev/null ; then
		eerror "emerge not found, did you bootstrap stage1 and stage2?"
		return 1
	fi

	# activate usr-split disabling in gen_usr_ldscript
	if [[ -n ${PREFIX_DISABLE_USR_SPLIT} ]] ; then
		export PREFIX_DISABLE_GEN_USR_LDSCRIPT=yes
	fi

	# Avoid circular deps caused by the default profiles (and IUSE defaults).
	local baseUSE="${USE}"
	export USE="-berkdb -fortran -gdbm -git -nls -pcre -readline -ssl -python bootstrap internal-glib ${baseUSE}"
	echo "app-shells/bash -readline # for bootstrap-prefix.sh" >> "${ROOT}"/etc/portage/make.profile/package.use.force

	# Python >= 3.2 fails to build on gcc-4.2. Disable it until after the sync.
	USE="-python_targets_python3_2 -python_targets_python3_3 ${USE}"
	echo ">=dev-lang/python-3 # for bootstrap-prefix.sh" >> "${ROOT}"/etc/portage/make.profile/package.mask

	# Most binary Linux distributions seem to fancy toolchains that
	# do not do c++ support (need to install a separate package).
	# Since we don't check for g++, just make sure binutils won't
	# try to build gold (needs c++), it will get there once we built
	# our own GCC with c++ support.  Getting there, requires us to have
	# a cxx compiler though, so since we can build one without any extra
	# deps with gcc, we should do so.
	USE="${USE} -cxx"
	{
		echo "sys-devel/gcc cxx # for bootstrap-prefix.sh"
		echo "sys-devel/gcc-apple cxx # for bootstrap-prefix.sh"
	} >> "${ROOT}"/etc/portage/make.profile/package.use.force

	# Need need to spam the user about news until the emerge -e default
	# because the tools aren't available to read the news item yet anyway.
	export FEATURES="-news ${FEATURES}"

	# Until we get a proper python, set correct PYTHONPATH for Portage,
	# since our stage1 Python lives in $EPREFIX/tmp, bug #407573
	export PYTHONPATH="${ROOT}"/tmp/usr/lib/portage/pym

	# stage2 has set a profile, which defines CHOST, so unset any CHOST
	# we've got here to avoid cross-compilation due to slight
	# differences caused by our guessing vs. what the profile sets.
	# This happens at least on 32-bits Darwin, with i386 and i686.
	# https://bugs.gentoo.org/show_bug.cgi?id=433948
	export bootstrapCHOST=${CHOST}
	unset CHOST

	# Find out what toolchain packages we need, and configure LDFLAGS
	# and friends.
	configure_toolchain || return 1

	[[ ${OFFLINE_MODE} ]] && \
		export FETCHCOMMAND="bash -c 'echo I need \\\$1 from \\\$2 in \\\$3; read' -- \\\${FILE} \\\${URI} \\\${DISTDIR}"

	emerge_pkgs() {
		local opts=$1 ; shift
		local pkg vdb pvdb evdb
		for pkg in "$@"; do
			vdb=${pkg}
			if [[ ${vdb} == "="* ]] ; then
				vdb=${vdb#=}
			elif [[ ${vdb} == "<"* ]] ; then
				vdb=${vdb#<}
				vdb=${vdb%-r*}
				vdb=${vdb%-*}
				vdb=${vdb}-\*
			else
				vdb=${vdb}-\*
			fi
			for pvdb in ${ROOT}/var/db/pkg/${vdb%-*}-* ; do
				if [[ -d ${pvdb} ]] ; then
					evdb=${pvdb##*/}
					if [[ ${pkg} == "="* ]] ; then
						# exact match required (* should work here)
						[[ ${evdb} == ${vdb##*/} ]] && break
					else
						vdb=${vdb%-*}
						evdb=${evdb%-r*}
						evdb=${evdb%_p*}
						evdb=${evdb%-*}
						[[ ${evdb} == ${vdb#*/} ]] && break
					fi
				fi
				pvdb=
			done
			[[ -n ${pvdb} ]] && continue

			eval 'emerge -v --oneshot ${opts} "${pkg}"'
			[[ $? -eq 0 ]] || return 1
		done
	}
	local pkgs

	emerge_pkgs --nodeps "sys-apps/sed" || return 1

	[[ ${bootstrapCHOST} != *-aix* ]] || # avoid hell with shared libiconv.a
	emerge_pkgs --nodeps "dev-libs/libiconv" || return 1
 
	# Hack for bash because curses is not always available (linux).
	# Disable collision-protect to overwrite the symlinked bin/bash for
	# a valid shebang we have symlinked bin/bash already
	FEATURES="${FEATURES} -collision-protect" \
	EXTRA_ECONF="--without-curses" \
		emerge_pkgs --nodeps "app-shells/bash" || return 1

	# we can now use our own bash throughout
	export CONFIG_SHELL="${ROOT}/bin/bash"

	pkgs=(
		app-arch/xz-utils
		sys-apps/baselayout-prefix
		sys-devel/m4
		sys-devel/flex
	)
	emerge_pkgs --nodeps "${pkgs[@]}" || return 1

	# >=bison-2.7.1's configure checks for perl, but doesn't use it,
	# except for tests. And bison-3 may want to run makeinfo.
	# Since we don't want to pull in perl at this stage, fake it
	PERL=$(which touch) \
	MAKEINFO="echo makeinfo GNU texinfo 4.13" \
		emerge_pkgs --nodeps "sys-devel/bison" || return 1

	pkgs=(
		sys-devel/patch
		sys-devel/binutils-config
		sys-devel/gcc-config
	)
	emerge_pkgs --nodeps "${pkgs[@]}" || return 1

	# we need pax-utils this early for OSX (before libiconv - gen_usr_ldscript)
	# but also for perl, which uses scanelf/scanmacho to find compatible
	# lib-dirs. Useless on AIX.
	# NOTE: no longer necessary on OSX with no /usr-split, no longer
	# necessary for perl when we have a snapshot with latest perl ebuild
	[[ ${bootstrapCHOST} == *-aix* ]] ||
	emerge_pkgs --nodeps "app-misc/pax-utils" || return 1

	# Clang on OSX defaults to c99 mode, while GCC defaults to gnu89
	# (C90 + extensions).  This makes Clang barf on GCC's sources, so
	# work around that.  Bug #491098
	GCC_CC=${CC}
	[[ ${bootstrapCHOST} == *-darwin* ]] && GCC_CC="${CC} -std=gnu89"
	# GCC sometimes decides that it needs to run makeinfo to update some
	# info pages from .texi files.  Obviously we don't care at this
	# stage and rather have it continue instead of abort the build
	# binutils does likewise, but also checks if the version is
	# sufficient, hence we trick it with --version output
	MAKEINFO="echo makeinfo GNU texinfo 4.13" CC="${GCC_CC}" \
		emerge_pkgs --nodeps "${toolchainpackages[@]}" || return 1

	# --oneshot
	pkgs=(
		sys-apps/coreutils
		sys-apps/findutils
		app-arch/tar
		sys-apps/grep
		sys-apps/gawk
		sys-devel/make
		sys-libs/zlib
		sys-apps/file
		app-admin/eselect
		virtual/os-headers
	)
	emerge_pkgs "" "${pkgs[@]}" || return 1

	pkgs=(
		sys-devel/gettext
		net-misc/wget
	)
	[[ ${OFFLINE_MODE} ]] || emerge_pkgs "" "${pkgs[@]}" || return 1

	# for some yet unknown reason, libxml2 has a problem with zlib, but
	# only during this stage, in the emerge -e system phase it is fine
	# it boils down to zlib headers replacing gzopen with gzopen64, but
	# no gzopen64 prototype being defined, due to libxml.h messing with
	# FILE_OFFSET_BITS
	# we can work around this by defining NO_LARGEFILE_SOURCE for libxml.h
	# since we have the compiler emerged, it's no problem we wipe out
	# the -I directions set by the profile
	export CPPFLAGS="${CPPFLAGS} -DNO_LARGEFILE_SOURCE"

	# bash needs to be compiled with USE=readline for Portage
	export USE="${USE//-readline/}"

	# disable collision-protect to overwrite the bootstrapped portage
	FEATURES="-collision-protect" emerge_pkgs "" "sys-apps/portage" || return 1

	unset CPPFLAGS

	# Each package emerged while portage was depending on the temporary tools
	# still may depend on them too. Examples are:
	#   binutils, xz-utils needing libgcc_s.so.1 on 64-bits Solaris
	#   shebangs (bin/egrep) originate in PORTAGE_SHELL
	# So we must keep the temporary tools until 'emerge -e system' is done.

	# kill temporary profile pollution
	find "${ROOT}"/usr/portage/profiles -type f -exec sed -i -e '/# for bootstrap-prefix.sh$/d' {} +

	treedate=$(date -f "${ROOT}"/usr/portage/metadata/timestamp +%s)
	nowdate=$(date +%s)
	if [[ ${OFFLINE_MODE} ]]; then
	  	# --keep used ${DISTDIR}, which make it easier to download a snapshot beforehand
		[[ ( ! -e ${PORTDIR}/.unpacked ) && $((nowdate - (60 * 60 * 24))) -lt ${treedate} ]] || emerge-webrsync --keep || return 1
	else
		[[ ( ! -e ${PORTDIR}/.unpacked ) && $((nowdate - (60 * 60 * 24))) -lt ${treedate} ]] || emerge --sync || emerge-webrsync || return 1
	fi

	export USE="${baseUSE}"
	unset PYTHONPATH CC HOSTCC CPPFLAGS LDFLAGS

	# activate last compiler (some Solaris cases), needed for mpc and
	# deps below
	gcc-config $(gcc-config -l | wc -l)

	# We need an up-to-date compiler before upgrading python to avoid
	# bug #490774
	emerge --oneshot -u ${pkggcc} || return 1

	# activate last compiler
	gcc-config $(gcc-config -l | wc -l)

	# Portage should figure out itself what it needs to do, if anything
	USE="-git" emerge -u system || return 1

	# avoid a circular dependency between glib and pkg-config
	emerge -u --newuse dev-util/pkgconfig || return 1

	# remove anything that we don't need (compilers most likely)
	emerge --depclean

	if [[ ! -f ${EPREFIX}/etc/portage/make.conf ]] ; then
		{
			echo 'USE="unicode nls"'
			echo 'CFLAGS="${CFLAGS} -O2 -pipe"'
			echo 'CXXFLAGS="${CFLAGS}"'
			echo "MAKEOPTS=\"${MAKEOPTS}\""
			echo "CONFIG_SHELL=\"${CONFIG_SHELL}\""
			if [[ -n ${PREFIX_DISABLE_USR_SPLIT} ]] ; then
				echo "# be careful with this one, don't just remove it!"
				echo "PREFIX_DISABLE_GEN_USR_LDSCRIPT=yes"
			fi
			[[ -n $PORTDIR_OVERLAY ]] && \
				echo "PORTDIR_OVERLAY=\"\${PORTDIR_OVERLAY} ${PORTDIR_OVERLAY}\""
			[[ ${OFFLINE_MODE} ]] && \
				echo 'FETCHCOMMAND="bash -c \"echo I need \${FILE} from \${URI} in \${DISTDIR}; read\""'
		} > "${EPREFIX}"/etc/portage/make.conf
	fi

	einfo "stage3 successfully finished"
}

bootstrap_interactive() {
	# No longer support gen_usr_ldscript stuff and the /usr split it
	# works around for in new bootstraps, this must be in line with what
	# eventually ends up in make.conf, see the end of stage3.  We don't
	# do this in bootstrap_setup() because in that case we'd also have
	# to cater for getting this right with manual bootstraps.
	export PREFIX_DISABLE_USR_SPLIT=yes 

	# immediately die on platforms that we know are impossible due to
	# brain-deadness (Debian/Ubuntu) or extremely hard dependency chains
	# (TODO NetBSD/OpenBSD)
	case ${CHOST} in
		*-linux-gnu)
			local toolchain_impossible=
			# Figure out if this is Ubuntu...
			if [[ $(lsb_release -is 2>/dev/null) == "Ubuntu" ]] ; then
				case "$(lsb_release -sr)" in
					[456789].*|10.*)
						: # good versions
						;;
					*)
						# Debian/Ubuntu have seriously fscked up their
						# toolchain to support their multi-arch crap
						# since Natty (11.04) that noone really wants,
						# and certainly not upstream.  Some details:
						# https://bugs.launchpad.net/ubuntu/+source/binutils/+bug/738098
						toolchain_impossible="Ubuntu >= 11.04 (Natty)"
						;;
				esac
			fi
			# Figure out if this is Debian
			if [[ -e /etc/debian_release ]] ; then
				case "$(< /etc/debian_release)" in
					hamm/*|slink/*|potato/*|woody/*|sarge/*|etch/*|lenny/*|squeeze/*)
						: # good versions
						;;
					*)
						# Debian introduced their big crap since Wheezy
						# (7.0), like for Ubuntu, see above
						toolchain_impossible="Debian >= 7.0 (Wheezy)"
						;;
				esac
			fi
			if [[ -n ${toolchain_impossible} ]] ; then
				# In short, it's impossible for us to compile a
				# compiler, since 1) gcc picks up our ld, which doesn't
				# support sysroot (can work around with a wrapper
				# script), 2) headers and libs aren't found (symlink
				# them to Prefix), 3) stuff like crtX.i isn't found
				# during bootstrap, since the bootstrap compiler doesn't
				# get any of our flags and doesn't know where to find
				# them (even if we copied them).  So we cannot do this,
				# unless we use the Ubuntu patches in our ebuilds, which
				# is a NO-GO area.
				cat << EOF
Oh My!  ${toolchain_impossible}!  AAAAAAAAAAAAAAAAAAAAARGH!  HELL comes over me!

EOF
				echo -n "..."
				sleep 1
				echo -n "."
				sleep 1
				echo -n "."
				sleep 1
				echo -n "."
				sleep 1
				echo
				echo
				cat << EOF
and over you.  You're on the worst Linux distribution from a developer's
(and so Gentoo Prefix) perspective since http://wiki.debian.org/Multiarch/.
Due to this multi-arch idea, it is IMPOSSIBLE for Gentoo Prefix to
bootstrap a compiler without using Debuntu patches, which is an absolute
NO-GO area!  GCC and binutils upstreams didn't just reject those patches
for fun.

I really can't help you, and won't waste any of your time either.  The
story simply ends here.  Sorry.
EOF
				exit 1
			fi
			;;
	esac

	cat <<"EOF"


                                             .
       .vir.                                d$b
    .d$$$$$$b.    .cd$$b.     .d$$b.   d$$$$$$$$$$$b  .d$$b.      .d$$b.
    $$$$( )$$$b d$$$()$$$.   d$$$$$$$b Q$$$$$$$P$$$P.$$$$$$$b.  .$$$$$$$b.
    Q$$$$$$$$$$B$$$$$$$$P"  d$$$PQ$$$$b.   $$$$.   .$$$P' `$$$ .$$$P' `$$$
      "$$$$$$$P Q$$$$$$$b  d$$$P   Q$$$$b  $$$$b   $$$$b..d$$$ $$$$b..d$$$
     d$$$$$$P"   "$$$$$$$$ Q$$$     Q$$$$  $$$$$   `Q$$$$$$$P  `Q$$$$$$$P
    $$$$$$$P       `"""""   ""        ""   Q$$$P     "Q$$$P"     "Q$$$P"
    `Q$$P"                                  """

             Welcome to the Gentoo Prefix interactive installer!


    I will attempt to install Gentoo Prefix on your system.  To do so, I'll
    ask  you some questions first.    After that,  you'll have to  practise
    patience as your computer and I try to figure out a way to get a lot of
    software  packages  compiled.    If everything  goes according to plan,
    you'll end up with what we call  "a Prefix install",  but by that time,
    I'll tell you more.


EOF
	[[ ${TODO} == 'noninteractive' ]] && ans=yes ||
	read -p "Do you want me to start off now? [Yn] " ans
	case "${ans}" in
		[Yy][Ee][Ss]|[Yy]|"")
			: ;;
		*)
			echo "Right.  Aborting..."
			exit 1
			;;
	esac

	if [[ ${UID} == 0 ]] ; then
		cat << EOF

Hmmm, you appear to be root, or at least someone with UID 0.  I really
don't like that.  The Gentoo Prefix people really discourage anyone
running Gentoo Prefix as root.  As a matter of fact, I'm just refusing
to help you any further here.
If you insist, you'll have go without my help, or bribe me.
EOF
		exit 1
	fi
	echo
	echo "It seems to me you are '${USER:-$(whoami 2> /dev/null)}' (${UID}), that looks cool to me."

	echo
	echo "I'm going to check for some variables in your environment now:"
	local flag dvar badflags=
	for flag in \
		ASFLAGS \
		CFLAGS \
		CPPFLAGS \
		CXXFLAGS \
		DYLD_LIBRARY_PATH \
		GREP_OPTIONS \
		LDFLAGS \
		LD_LIBRARY_PATH \
		LIBPATH \
		PERL_MM_OPT \
		PKG_CONFIG_PATH \
		PYTHONPATH \
	; do
		# starting on purpose a shell here iso ${!flag} because I want
		# to know if the shell initialisation files trigger this
		# note that this code is so complex because it handles both
		# C-shell as sh
		dvar="echo \"((${flag}=\${${flag}}))\""
		dvar="$(echo "${dvar}" | env -i HOME=$HOME $SHELL -l 2>/dev/null)"
		if [[ ${dvar} == *"((${flag}="?*"))" ]] ; then
			badflags="${badflags} ${flag}"
			dvar=${dvar#*((${flag}=}
			dvar=${dvar%%))*}
			echo "  uh oh, ${flag}=${dvar} :("
		else
			echo "  it appears ${flag} is not set :)"
		fi
		# unset for the current environment
		unset ${flag}
	done
	if [[ -n ${badflags} ]] ; then
		cat << EOF

Ahem, your shell environment contains some variables I'm allergic to:
 ${badflags}
These flags can and will influence the way in which packages compile.
In fact, they have a long standing tradition to break things.  I really
prefer to be on my own here.  So please make sure you disable these
environment variables in your shell initialisation files.  After you've
done that, you can run me again.
EOF
		exit 1
	fi
	echo
	echo "I'm excited!  Seems we can finally do something productive now."

	cat << EOF

Ok, I'm going to do a little bit of guesswork here.  Thing is, your
machine appears to be identified by CHOST=${CHOST}.
EOF
	case "${CHOST}" in
		powerpc*|ppc*|sparc*)
			cat << EOF

To me, it seems to be a big-endian machine.  I told you before you need
patience, but with your machine, regardless how many CPUs you have, you
need some more.  Context switches are just expensive, and guess what
fork/execs result in all the time.  I'm going to make it even worse for
you, configure and make typically are fork/exec bombs.
I'm going to assume you're actually used to having patience with this
machine, which is good, because I really love a box like yours!
EOF
			;;
	esac

	# eventually the user does know where to find a compiler
	[[ ${TODO} == 'noninteractive' ]] &&
	usergcc=$(type -P gcc 2>/dev/null)

	# the standard path we want to start with, override anything from
	# the user on purpose
	PATH="/usr/bin:/bin"
	# don't exclude the path to bash if it isn't in a standard location
	type -P bash > /dev/null || PATH="${BASH%/bash}:${PATH}"
	case "${CHOST}" in
		*-solaris*)
			cat << EOF

Ok, this is Solaris, or a derivative like OpenSolaris or OpenIndiana.
Sometimes, useful tools necessary at this stage are hidden.  I'm going
to check if that's the case for your system too, and if so, add those
locations to your PATH.
EOF
			# could do more "smart" CHOST deductions here, but brute
			# force is most likely as quick, but simpler
			[[ -d /usr/sfw/bin ]] \
				&& PATH="${PATH}:/usr/sfw/bin"
			[[ -d /usr/sfw/i386-sun-solaris${CHOST##*-solaris}/bin ]] \
				&& PATH="${PATH}:/usr/sfw/i386-sun-solaris${CHOST##*-solaris}/bin"
			[[ -d /usr/sfw/sparc-sun-solaris${CHOST##*-solaris}/bin ]] \
				&& PATH="${PATH}:/usr/sfw/sparc-sun-solaris${CHOST##*-solaris}/bin"
			# OpenIndiana 151a5
			[[ -d /usr/gnu/bin ]] && PATH="${PATH}:/usr/gnu/bin"
			# SmartOS
			[[ -d /opt/local/gcc47/bin ]] && PATH="${PATH}:/opt/local/gcc47/bin"
			;;
	esac

	# TODO: should we better use cc here? or check both?
	if ! type -P gcc > /dev/null ; then
		case "${CHOST}" in
			*-darwin*)
				cat << EOF

Uh oh... a Mac OS X system, but without compiler.  You must have
forgotten to install Xcode tools.  If your Mac didn't come with an
install DVD (pre Lion) you can find it in the Mac App Store, or download
the Xcode command line tools from Apple Developer Connection.  If you
did get a CD/DVD with your Mac, there is a big chance you can find Xcode
on it, and install it right away.
Please do so, and try me again!
EOF
				exit 1
				;;
			*-solaris2.[789]|*-solaris2.10)
				cat << EOF

Yikes!  Your Solaris box doesn't come with gcc in /usr/sfw/blabla/bin?
What good is it to me then?  I can't find a compiler!  I'm afraid
you'll have to find a way to install the Sun FreeWare tools somehow, is
it on the Companion disc perhaps?
See me again when you figured it out.
EOF
				exit 1
				;;
			*-solaris*)
				SOLARIS_RELEASE=$(head -n1 /etc/release)
				if [[ ${SOLARIS_RELEASE} == *"Oracle Solaris"* ]] ; then
					cat << EOF
Seems like you have installed Oracle Solaris ${SOLARIS_RELEASE}.
I suppose you have solaris publisher set.  If not, use:
  pkg set-publisher -p http://pkg.oracle.com/solaris/release
You need to install some necessary packages:
  pkg install developer/gcc-45 system/header
In the meanwhile, I'll wait here until you run me again, with a compiler.
EOF
				else
					cat << EOF

Sigh.  This is OpenSolaris or OpenIndiana?  I can't tell the difference
without looking more closely.  What I DO know, is that there is no
compiler, at least not where I was just looking, so how do we continue
from here, eh?  I just think you didn't install one.  I know it can be
tricky on OpenIndiana, for instance, so won't blame you.  In case you're
on OpenIndiana, I'll help you a bit.  Perform the following as
super-user:
  pkg install developer/gnu system/library/math/header-math
In the meanwhile, I'll wait here until you run me again, with a compiler.
EOF
				fi
				exit 1
				;;
			*)
				cat << EOF

Well, well... let's make this painful situation as short as it can be:
you don't appear to have a compiler around for me to play with.
Since I like your PATH to be as minimal as possible, I threw away
everything you put in it, and started from scratch.  Perhaps, the almost
impossible happened that I was wrong in doing so.
Ok, I'll give you a chance.  You can now enter what you think is
necessary to add to PATH for me to find a compiler.  I start off with
PATH=${PATH} and will add anything you give me here.
EOF
				[[ ${TODO} == 'noninteractive' ]] && ans="${usergcc%/gcc}" ||
				read -p "Where can I find your compiler? [] " ans
				case "${ans}" in
					"")
						: ;;
					*)
						PATH="${PATH}:${ans}"
						;;
				esac
				if ! type -P gcc > /dev/null ; then
					cat << EOF

Are you sure you have a compiler?  I didn't find one.  I think you
better first go get one, then run me again.
EOF
					exit 1
				else
					echo
					echo "Pfff, ok, it seems you were right.  Can we move on now?"
				fi
			;;
		esac
	else
		echo
		echo "Great!  You appear to have a compiler in your PATH"
	fi

	if type -P xcode-select > /dev/null && [[ ! -d /usr/include ]] ; then
		# bug #512032
		cat << EOF

You don't have /usr/include, this thwarts me to build stuff.
Please execute:
  xcode-select --install
or install /usr/include in another way and try running me again.
EOF
		exit 1
	fi

	echo
	local ncpu=
    case "${CHOST}" in
		*-darwin*)     ncpu=$(/usr/sbin/sysctl -n hw.ncpu)                 ;;
		*-freebsd*)    ncpu=$(/sbin/sysctl -n hw.ncpu)                     ;;
		*-solaris*)    ncpu=$(/usr/sbin/psrinfo | wc -l)                   ;;
        *-linux-gnu*)  ncpu=$(cat /proc/cpuinfo | grep processor | wc -l)  ;;
        *-aix*)        ncpu=$(/usr/sbin/bindprocessor -q | cut -d: -f2 | wc -w) ;;
        *-hpux*)       ncpu=$(/sbin/ioscan -kC processor | grep -c processor) ;;
        *)             ncpu=1                                              ;;
    esac
	# get rid of excess spaces (at least Solaris wc does)
	ncpu=$((ncpu + 0))
	# Suggest usage of 100% to 60% of the available CPUs in the range
	# from 1 to 14.  We limit to no more than 8, since we easily flood
	# the bus on those heavy-core systems and only slow down in that
	# case anyway.
	local tcpu=$((ncpu / 2 + 1))
	[[ ${tcpu} -gt 8 ]] && tcpu=8
	cat << EOF

I did my utmost best, and found that you have ${ncpu} cpu cores.  If
this looks wrong to you, you can happily ignore me.  Based on the number
of cores you have, I came up with the idea of parallelising compilation
work where possible with ${tcpu} parallel make threads.  If you have no
clue what this means, you should go with my excellent default I've
chosen below, really!
EOF
	[[ ${TODO} == 'noninteractive' ]] && ans="" ||
	read -p "How many parallel make jobs do you want? [${tcpu}] " ans
	case "${ans}" in
		"")
			MAKEOPTS="-j${tcpu}"
			;;
		*)
			if [[ ${ans} -le 0 ]] ; then
				echo
				echo "You should have entered a non-zero integer number, obviously..."
				exit 1
			elif [[ ${ans} -gt ${tcpu} && ${tcpu} -ne 1 ]] ; then
				if [[ ${ans} -gt ${ncpu} ]] ; then
					cat << EOF

Want to push it very hard?  I already feel sorry for your poor box with
its mere ${ncpu} cpu cores.
EOF
				elif [[ $((ans - tcpu)) -gt 1 ]] ; then
					cat << EOF

So you think you can stress your system a bit more than my extremely
well thought out formula suggested you?  Hmmpf, I'll take it you know
what you're doing then.
EOF
					sleep 1
					echo "(are you?)"
				fi
			fi
			MAKEOPTS="-j${ans}"
			;;
	esac
	export MAKEOPTS

	#32/64 bits, multilib
	local candomultilib=no
	local t64 t32
	case "${CHOST}" in
		*86*-darwin9|*86*-darwin1[012])
			# PPC/Darwin only works in 32-bits mode, so this is Intel
			# only, and only starting from Leopard (10.5, darwin9)
			candomultilib=yes
			t64=x86_64-${CHOST#*-}
			t32=i686-${CHOST#*-}
			;;
		*-solaris*)
			# Solaris is a true multilib system from as long as it does
			# 64-bits, we only need to know if the CPU we use is capable
			# of doing 64-bits mode
			[[ $(/usr/bin/isainfo | tr ' ' '\n' | wc -l) -ge 2 ]] \
				&& candomultilib=yes
			if [[ ${CHOST} == sparc* ]] ; then
				t64=sparcv9-${CHOST#*-}
				t32=sparc-${CHOST#*-}
			else
				t64=x86_64-${CHOST#*-}
				t32=i386-${CHOST#*-}
			fi
			;;
		# Even though multilib on Linux is often supported in some way,
		# it's hardly ever installed by default (it seems)
		# Since it's non-trivial to figure out if such system (binary
		# packages can report to be multilib, but lack all necessary
		# libs) is truely multilib capable, we don't bother here.  The
		# user can override if he/she is really convinced the system can
		# do it.
	esac
	if [[ ${candomultilib} == yes ]] ; then
		cat << EOF

Your system appears to be a multilib system, that is in fact also
capable of doing multilib right here, right now.  Multilib means
something like "being able to run multiple kinds of binaries".  The most
interesting kind for you now is 32-bits versus 64-bits binaries.  I can
create both a 32-bits as well as a 64-bits Prefix for you, but do you
actually know what I'm talking about here?  If not, just accept the
default here.  Honestly, you don't want to change it if you can't name
one advantage of 64-bits over 32-bits other than that 64 is a higher
number and when you buy a car or washing machine, you also always choose
the one with the highest number.
EOF
		[[ ${TODO} == 'noninteractive' ]] && ans="" ||
		case "${CHOST}" in
			x86_64-*|sparcv9-*)  # others can't do multilib, so don't bother
				# 64-bits native
				read -p "How many bits do you want your Prefix to target? [64] " ans
				;;
			*)
				# 32-bits native
				read -p "How many bits do you want your Prefix to target? [32] " ans
				;;
		esac
		case "${ans}" in
			"")
				: ;;
			32)
				CHOST=${t32}
				;;
			64)
				CHOST=${t64}
				;;
			*)
				cat << EOF

${ans}? Yeah Right(tm)!  You obviously don't know what you're talking
about, so I'll take the default instead.
EOF
				;;
		esac
	fi
	export CHOST

	# choose EPREFIX, we do this last, since we have to actually write
	# to the filesystem here to check that the EPREFIX is sane
	cat << EOF

Each and every Prefix has a home.  That is, a place where everything is
supposed to be in.  That place must be fully writable by you (duh), but
should also be able to hold some fair amount of data and preferably be
reasonably fast.  In terms of space, I advise something around 2GiB
(it's less if you're lucky).  I suggest a reasonably fast place because
we're going to compile a lot, and that generates a fair bit of IO.  If
some networked filesystem like NFS is the only option for you, then
you're just going to have to wait a fair bit longer.
This place which is your Prefix' home, is often referred to by a
variable called EPREFIX.
EOF
	while true ; do
		if [[ -z ${EPREFIX} ]] ; then
			# Make the default for Mac users a bit more "native feel"
			[[ ${CHOST} == *-darwin* ]] \
				&& EPREFIX=$HOME/Gentoo \
				|| EPREFIX=$HOME/gentoo
		fi
		echo
		[[ ${TODO} == 'noninteractive' ]] && ans=${ROOT} ||
		read -p "What do you want EPREFIX to be? [$EPREFIX] " ans
		case "${ans}" in
			"")
				: ;;
			/*)
				EPREFIX=${ans}
				;;
			*)
				echo
				echo "EPREFIX must be an absolute path!"
				[[ ${TODO} == 'noninteractive' ]] && exit 1
				EPREFIX=
				continue
				;;
		esac
		if [[ ! -d ${EPREFIX} ]] && ! mkdir -p "${EPREFIX}" ; then
			echo
			echo "It seems I cannot create ${EPREFIX}."
			[[ ${TODO} == 'noninteractive' ]] && exit 1
			echo "I'll forgive you this time, try again."
			EPREFIX=
			continue
		fi
		#readlink -f would not work on darwin, so use bash builtins
		local realEPREFIX="$(cd "$EPREFIX"; pwd -P)"
		if [[ -z ${I_KNOW_MY_GCC_WORKS_FINE_WITH_SYMLINKS} && ${EPREFIX} != ${realEPREFIX} ]]; then
			echo
			echo "$EPREFIX contains a symlink, which will make the merge of gcc"
			echo "imposible, use '${realEPREFIX}' instead or"
			echo "export I_KNOW_MY_GCC_WORKS_FINE_WITH_SYMLINKS='hell yeah'"
			[[ ${TODO} == 'noninteractive' ]] && exit 1
			echo "Have another try."
			EPREFIX="${realEPREFIX}"
			continue
		fi
		if ! touch "${EPREFIX}"/.canihaswrite >& /dev/null ; then
			echo
			echo "I cannot write to ${EPREFIX}!"
			[[ ${TODO} == 'noninteractive' ]] && exit 1
			echo "You want some fun, but without me?  Try another location."
			EPREFIX=
			continue
		fi
		# don't really expect this one to fail
		rm -f "${EPREFIX}"/.canihaswrite || exit 1
		# location seems ok
		break;
	done
	export EPREFIX
	export PATH="$EPREFIX/usr/bin:$EPREFIX/bin:$EPREFIX/tmp/usr/bin:$EPREFIX/tmp/bin:$PATH"

	cat << EOF

OK!  I'm going to give it a try, this is what I have collected sofar:
  EPREFIX=${EPREFIX}
  CHOST=${CHOST}
  PATH=${PATH}
  MAKEOPTS=${MAKEOPTS}

I'm now going to make an awful lot of noise going through a sequence of
stages to make your box as groovy as I am myself, setting up your
Prefix.  In short, I'm going to run stage1, stage2, stage3, followed by
emerge -e system.  If any of these stages fail, both you and me are in
deep trouble.  So let's hope that doesn't happen.
EOF
	echo
	[[ ${TODO} == 'noninteractive' ]] && ans="" ||
	read -p "Type here what you want to wish me [luck] " ans
	if [[ -n ${ans} && ${ans} != "luck" ]] ; then
		echo "Huh?  You're not serious, are you?"
		sleep 3
	fi
	echo

	if ! [[ -x ${EPREFIX}/usr/lib/portage/bin/emerge ]] && ! ${BASH} ${BASH_SOURCE[0]} "${EPREFIX}/tmp" stage1 ; then
		# stage 1 fail
		cat << EOF

I tried running
  ${BASH} ${BASH_SOURCE[0]} "${EPREFIX}/tmp" stage1
but that failed :(  I have no clue, really.  Please find friendly folks
in #gentoo-prefix on irc.gentoo.org, gentoo-alt@lists.gentoo.org mailing list,
or file a bug at bugs.gentoo.org under Gentoo/Alt, Prefix Support.
Sorry that I have failed you master.  I shall now return to my humble cave.
EOF
		exit 1
	fi

	if ! [[ -x ${EPREFIX}/usr/lib/portage/bin/emerge ]] && ! ${BASH} ${BASH_SOURCE[0]} "${EPREFIX}" stage2 ; then
		# stage 2 fail
		cat << EOF

Odd!  Running
  ${BASH} ${BASH_SOURCE[0]} "${EPREFIX}" stage2
failed! :(  I have no clue, really.  Please find friendly folks in
#gentoo-prefix on irc.gentoo.org, gentoo-alt@lists.gentoo.org mailing list, or
file a bug at bugs.gentoo.org under Gentoo/Alt, Prefix Support.
I am defeated.  I am of no use here any more.
EOF
		exit 1
	fi

	# after stage1 and stage2 we should have a bash of our own, which
	# is preferably over the host-provided one, because we know it can
	# deal with the bash-constructs we use in stage3 and onwards
	hash -r

	if ! bash ${BASH_SOURCE[0]} "${EPREFIX}" stage3 ; then
		# stage 3 fail
		hash -r  # previous cat (tmp/usr/bin/cat) may have been removed
		cat << EOF

Hmmmm, I was already afraid of this to happen.  Running
  $(type -P bash) ${BASH_SOURCE[0]} "${EPREFIX}" stage3
somewhere failed :(  Details might be found in the build log:
EOF
		for log in "${EPREFIX}"/var/tmp/portage/*/*/temp/build.log ; do
			[[ -e ${log} ]] || continue
			echo "  ${log}"
		done
		[[ -e ${log} ]] || echo "  (no build logs found?!?)"
		cat << EOF
I have no clue, really.  Please find friendly folks in #gentoo-prefix on
irc.gentoo.org, gentoo-alt@lists.gentoo.org mailing list, or file a bug
at bugs.gentoo.org under Gentoo/Alt, Prefix Support.  This is most
inconvenient, and it crushed my ego.  Sorry, I give up.
EOF
		exit 1
	fi
	hash -r  # tmp/* stuff is removed in stage3

	# Don't confuse Portage with a possibly slightly differing CHOST
	unset CHOST

	if ! emerge -e system ; then
		# emerge -e system fail
		cat << EOF

Oh yeah, I thought I was almost there, and then this!  I did
  emerge -e system
and it failed at some point :(  Details might be found in the build log:
EOF
		for log in "${EPREFIX}"/var/tmp/portage/*/*/temp/build.log ; do
			[[ -e ${log} ]] || continue
			echo "  ${log}"
		done
		[[ -e ${log} ]] || echo "  (no build logs found?!?)"
		cat << EOF
I have no clue, really.  Please find friendly folks in #gentoo-prefix on
irc.gentoo.org, gentoo-alt@lists.gentoo.org mailing list, or file a bug
at bugs.gentoo.org under Gentoo/Alt, Prefix Support.
You know, I got the feeling you just started to like me, but I guess
that's all gone now.  I'll bother you no longer.
EOF
		exit 1
	fi

	# Now, after 'emerge -e system', we can get rid of the temporary tools.
	if [[ -d ${ROOT}/tmp/var/tmp ]] ; then
		rm -Rf "${ROOT}"/tmp || return 1
		mkdir -p "${ROOT}"/tmp || return 1
	fi

	if ! bash ${BASH_SOURCE[0]} "${EPREFIX}" startscript ; then
		# startscript fail?
		cat << EOF

Ok, let's be honest towards each other.  If
  $(type -P bash) ${BASH_SOURCE[0]} "${EPREFIX}" startscript
fails, then who cheated on who?  Either you use an obscure shell, or
your PATH isn't really sane afterall.  Despite, I can't really
congratulate you here, you basically made it to the end.
Please find friendly folks in #gentoo-prefix on irc.gentoo.org,
gentoo-alt@lists.gentoo.org mailing list, or file a bug at
bugs.gentoo.org under Gentoo/Alt, Prefix Support.
It's sad we have to leave each other this way.  Just an inch away...
EOF
		exit 1
	fi

	echo
	cat << EOF

Woah!  Everything just worked!  Now YOU should run
  ${EPREFIX}/startprefix
and enjoy!  Thanks for using me, it was a pleasure to work with you.
EOF
}

## End Functions

## some vars

# We do not want stray $TMP, $TMPDIR or $TEMP settings
unset TMP TMPDIR TEMP

# Try to guess the CHOST if not set.  We currently only support guessing
# on a very sloppy base.
if [[ -z ${CHOST} ]]; then
	if [[ x$(type -t uname) == "xfile" ]]; then
		case `uname -s` in
			Linux)
				case `uname -m` in
					ppc*)
						CHOST="`uname -m | sed -e 's/^ppc/powerpc/'`-unknown-linux-gnu"
						;;
					powerpc*)
						CHOST="`uname -m`-unknown-linux-gnu"
						;;
					*)
						CHOST="`uname -m`-pc-linux-gnu"
						;;
				esac
				;;
			Darwin)
				rev="`uname -r | cut -d'.' -f 1`"
				if [[ ${rev} -ge 11 ]] ; then
					# Lion and up are 64-bits default (and 64-bits CPUs)
					CHOST="x86_64-apple-darwin$rev"
				else
					CHOST="`uname -p`-apple-darwin$rev"
				fi
				;;
			SunOS)
				case `uname -p` in
					i386)
						CHOST="i386-pc-solaris`uname -r | sed 's|5|2|'`"
					;;
					sparc)
						CHOST="sparc-sun-solaris`uname -r | sed 's|5|2|'`"
					;;
				esac
				;;
			AIX)
				# GNU coreutils uname sucks, it doesn't know what
				# processor it is using on AIX.  We mimick GNU CHOST
				# guessing here, instead of what IBM uses itself.
				CHOST="`/usr/bin/uname -p`-ibm-aix`oslevel`"
				;;
			IRIX|IRIX64)
				CHOST="mips-sgi-irix`uname -r`"
				;;
			Interix)
				case `uname -m` in
					x86) CHOST="i586-pc-interix`uname -r`" ;;
					*) eerror "Can't deal with interix `uname -m` (yet)"
					   exit 1
					;;
				esac
				;;
			CYGWIN*)
				# http://www.cygwin.com/ml/cygwin/2009-02/msg00669.html
				case `uname -r` in
					1.7*)
						CHOST="`uname -m`-pc-cygwin1.7"
					;;
					*)
						CHOST="`uname -m`-pc-cygwin"
					;;
				esac
				;;
			HP-UX)
				case `uname -m` in
				ia64) HP_ARCH=ia64 ;;
				9000/[678][0-9][0-9])
					if [ ! -x /usr/bin/getconf ]; then
						eerror "Need /usr/bin/getconf to determine cpu"
						exit 1
					fi
					# from config.guess
					sc_cpu_version=`/usr/bin/getconf SC_CPU_VERSION 2>/dev/null`
					sc_kernel_bits=`/usr/bin/getconf SC_KERNEL_BITS 2>/dev/null`
					case "${sc_cpu_version}" in
					523) HP_ARCH="hppa1.0" ;; # CPU_PA_RISC1_0
					528) HP_ARCH="hppa1.1" ;; # CPU_PA_RISC1_1
					532)                      # CPU_PA_RISC2_0
						case "${sc_kernel_bits}" in
						32) HP_ARCH="hppa2.0n" ;;
						64) HP_ARCH="hppa2.0w" ;;
						'') HP_ARCH="hppa2.0" ;;   # HP-UX 10.20
						esac ;;
					esac
					;;
				esac
				uname_r=`uname -r`
				if [ -z "${HP_ARCH}" ]; then
					error "Cannot determine cpu/kernel type"
					exit ;
				fi
				CHOST="${HP_ARCH}-hp-hpux${uname_r#B.}"
				unset HP_ARCH uname_r
				;;
			FreeBSD)
				case `uname -p` in
					i386)
						CHOST="i386-pc-freebsd`uname -r | sed 's|-.*$||'`"
					;;
					amd64)
						CHOST="x86_64-pc-freebsd`uname -r | sed 's|-.*$||'`"
					;;
					sparc64)
						CHOST="sparc64-unknown-freebsd`uname -r | sed 's|-.*$||'`"
					;;
					*)
						eerror "Sorry, don't know about FreeBSD on `uname -p` yet"
						exit 1
					;;
				esac
				;;
			NetBSD)
				case `uname -p` in
					i386)
						CHOST="`uname -p`-pc-netbsdelf`uname -r`"
					;;
					*)
						eerror "Sorry, don't know about NetBSD on `uname -p` yet"
						exit 1
					;;
				esac
				;;
			OpenBSD)
				case `uname -m` in
					macppc)
						CHOST="powerpc-unknown-openbsd`uname -r`"
					;;
					i386)
						CHOST="i386-pc-openbsd`uname -r`"
					;;
					amd64)
						CHOST="x86_64-pc-openbsd`uname -r`"
					;;
					*)
						eerror "Sorry, don't know about OpenBSD on `uname -m` yet"
						exit 1
					;;
				esac
				;;
			*)
				eerror "Nothing known about platform `uname -s`."
				eerror "Please set CHOST appropriately for your system"
				eerror "and rerun $0"
				exit 1
				;;
		esac
	fi
fi

# Now based on the CHOST set some required variables.  Doing it here
# allows for user set CHOST still to result in the appropriate variables
# being set.
case ${CHOST} in
	*-*-solaris*)
		if type -P gmake > /dev/null ; then
			MAKE=gmake
		else
			MAKE=make
		fi
	;;
	*-sgi-irix*)
		MAKE=gmake
	;;
	*-aix*)
		MAKE=make
		# We do run in bash here, no? It is ways faster than /bin/sh.
		: ${CONFIG_SHELL:=${BASH}}
		;;
	*)
		MAKE=make
	;;
esac

# deal with a problem on OSX with Python's locales
case ${CHOST}:${LC_ALL}:${LANG} in
	*-darwin*:UTF-8:*|*-darwin*:*:UTF-8)
		eerror "Your LC_ALL and/or LANG is set to 'UTF-8'."
		eerror "This setting is known to cause trouble with Python.  Please run"
		case ${SHELL} in
			*/tcsh|*/csh)
				eerror "  setenv LC_ALL en_US.UTF-8"
				eerror "  setenv LANG en_US.UTF-8"
				eerror "and make it permanent by adding it to your ~/.${SHELL##*/}rc"
				exit 1
			;;
			*)
				eerror "  export LC_ALL=en_US.UTF-8"
				eerror "  export LANG=en_US.UTF-8"
				eerror "and make it permanent by adding it to your ~/.profile"
				exit 1
			;;
		esac
	;;
esac

# Just guessing a prefix is kind of scary.  Hence, to make it a bit less
# scary, we force the user to give the prefix location here.  This also
# makes the script a bit less dangerous as it will die when just run to
# "see what happens".
if [[ -n $1 && -z $2 ]] ; then
	echo "usage: $0 [<prefix-path> <action>]"
	echo
	echo "Either you give no argument and I'll ask you interactively, or"
	echo "you need to give both the path offset for your Gentoo prefixed"
	echo "portage installation, and the action I should do there, e.g."
	echo "  $0 $HOME/prefix <action>"
	echo
	echo "See the source of this script for which actions exist."
	echo
	echo "$0: insufficient number of arguments" 1>&2
	exit 1
elif [[ -z $1 ]] ; then
	bootstrap_interactive
	exit 0
fi

ROOT="$1"

case $ROOT in
	chost.guess)
		# undocumented feature that sort of is our own config.guess, if
		# CHOST was unset, it now contains the guessed CHOST
		echo "$CHOST"
		exit 0
	;;
	/*) ;;
	*)
		echo "Your path offset needs to be absolute!" 1>&2
		exit 1
	;;
esac

CXXFLAGS="${CXXFLAGS:-${CFLAGS}}"
PORTDIR=${PORTDIR:-"${ROOT}/usr/portage"}
DISTDIR=${DISTDIR:-"${PORTDIR}/distfiles"}
PORTAGE_TMPDIR=${ROOT}/var/tmp
DISTFILES_URL="http://dev.gentoo.org/~grobian/distfiles"
SNAPSHOT_URL="http://prefix.gentooexperimental.org/snapshots"
GNU_URL=${GNU_URL:="http://ftp.gnu.org/gnu"}
GENTOO_MIRRORS=${GENTOO_MIRRORS:="http://distfiles.gentoo.org"}
GCC_APPLE_URL="http://www.opensource.apple.com/darwinsource/tarballs/other"

export MAKE CONFIG_SHELL


einfo "Bootstrapping Gentoo prefixed portage installation using"
einfo "host:   ${CHOST}"
einfo "prefix: ${ROOT}"

TODO=${2}
if [[ ${TODO} != "noninteractive" && $(type -t bootstrap_${TODO}) != "function" ]];
then
	eerror "bootstrap target ${TODO} unknown"
	exit 1
fi

if [[ -n ${LD_LIBARY_PATH} || -n ${DYLD_LIBRARY_PATH} ]] ; then
	eerror "EEEEEK!  You have LD_LIBRARY_PATH or DYLD_LIBRARY_PATH set"
	eerror "in your environment.  This is a guarantee for TROUBLE."
	eerror "Cowardly refusing to operate any further this way!"
	exit 1
fi

if [[ -n ${PKG_CONFIG_PATH} ]] ; then
	eerror "YUK!  You have PKG_CONFIG_PATH set in your environment."
	eerror "This is a guarantee for TROUBLE."
	eerror "Cowardly refusing to operate any further this way!"
	exit 1
fi

einfo "ready to bootstrap ${TODO}"
# bootstrap_interactive proceeds with guessed defaults when TODO=noninteractive
bootstrap_${TODO#non} || exit 1
