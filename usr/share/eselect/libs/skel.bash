# -*-eselect-*-  vim: ft=eselect
# Copyright (c) 2006-2014 Gentoo Foundation
#
# This file is part of the 'eselect' tools framework.
#
# eselect is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 2 of the License, or (at your option) any later
# version.
#
# eselect is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# eselect.  If not, see <http://www.gnu.org/licenses/>.

# This library provides for a simple eselect module to switch between
# implementations of anything that installs to a "lib*" directory (i.e.,
# lib, lib32, lib64). This will satisfy the requirements for most cases
# in which one must switch between providers of a certain library or any
# package installing a library.
#
# Creating a simple module:
# To use this library, all you need to do is create an eselect module
# containing settings for the MODULE and IFACE variables. The MODULE
# variable is the name used to refer to the implementations being
# switched in help text. The IFACE variable indicates the subdirectory
# of /etc/env.d/ in which eselect config files for these implementations
# will be stored.
#
# Each package must install a symlink map using the "add" action.
# The map must use relative symlinks, one source-destination mapping per
# line in the form "source destination". The source must be relative
# to the destination, not absolute. In other words, "source" must be
# relative to "destination" but "destination" must be absolute. One
# caveat about the symlink map - instead of using "lib" or "lib64" etc.,
# you must use @LIBDIR@. The "skel.bash" library detects the proper
# library directory at runtime.

# There is a file installed at /etc/env.d/$IFACE/$libdir/config
# containing the CURRENT variable, which is set to the current eselect
# setting. Also, each implementation installs a single file at
# /etc/env.d/$IFACE/$libdir/$implem containing the symlink map. You may
# have comments in the symlink map file - any line containing a '#' is
# considered a comment.

inherit config multilib tests

# find_implems $iface $libdir
# find all possible implems for $libdir
find_implems() {
	local -a implems
	local confdir=${EROOT}/etc/env.d/${iface}/${libdir}
	iface=$1 libdir=$2
	for file in "${confdir}"/* ; do
		[[ -f ${file} ]] || continue
		[[ "${file##*/}" != "config" ]] || continue
		implems=(${implems[@]} "${file##*/}")
	done
	echo ${implems[@]}
}

# is_active $iface $libdir $implem
# returns true if $implem is currently used for the $iface/$libdir combination
is_active() {
	[[ $# -eq 3 ]] || die "Need exactly 3 arguments!"
	current=$(load_config "${EROOT}/etc/env.d/${1}/${2}/config" CURRENT)
	[[ ${current} == ${3} ]]
}

# switch_implem $iface $libdir $implem
# switches $iface/$libdir combination to $implem
switch_implem() {
	# set us up
	[[ $# -eq 3 ]] || die "Need exactly 3 arguments!"
	local iface=${1}
	local libdir=${2}
	local implem=${3##*/}
	local confdir=${EROOT}/etc/env.d/${iface}/${libdir}
	local current=$(load_config "${confdir}/config" CURRENT)
	local dest src

	# Get rid of old symlinks, if we have a current config
	if [[ -f ${confdir}/${current} ]]; then
		while read line; do
			# Skip comments
			[[ "${line}" = *#* ]] && continue

			line=${line//@LIBDIR@/${libdir}}

			set ${line}
			dest=$2
			rm -f "${ROOT}${dest}"
		done < "${confdir}/${current}"
	fi

	# Set up new symlinks
	while read line; do
		# Skip comments
		[[ "${line}" = *#* ]] && continue

		line=${line//@LIBDIR@/${libdir}}

		set ${line}
		src=$1
		dest=$2
		ln -sf "${src}" "${ROOT}${dest}"
	done < "${confdir}/${implem}"

	store_config "${confdir}/config" CURRENT ${implem}
}

# iface_do_list $libdir
# Lists the available implementations for $libdir
iface_do_list() {
	local -a implems
	local libdir=$1 iface=$IFACE
	implems=( $(find_implems $iface $libdir ) )

	# None installed for $libdir
	[[ -z ${implems[@]} ]] \
		&& return

	write_list_start "Installed $MODULE for library directory $(highlight ${libdir})"
	for implem in ${implems[@]} ; do
		(( i++ ))
		is_active ${iface} ${libdir} ${implem##*/} \
			&& implem=$(highlight_marker "${implem}")
		write_numbered_list_entry $i "${implem}"
	done
}

# iface_do_show $libdir
# Shows the current implementation for $libdir
iface_do_show() {
	local iface=$IFACE libdir=$1 implem
	local confdir=${EROOT}/etc/env.d/${iface}/${libdir}
	[[ -e ${confdir}/config ]] || return

	implem=$(load_config "${confdir}/config" CURRENT)
	[[ -e ${confdir}/${implem} ]] \
		|| die "File \"${confdir}/${implem}\" is missing!"

	echo "${libdir}: ${implem}"
}

# get_libdirs
# Wraps list_libdirs() to ensure that output is sorted consistently
get_libdirs() {
	list_libdirs | sort
}

### list action

describe_list() {
	echo "List all installed $MODULE implementations"
}

do_list() {
	local libdir
	# Count for listing IFACE/libdir combinations
	# We keep it here so it doesn't reset on every call to iface_do_list()
	local i=0

	for libdir in $(get_libdirs); do
		[[ -d ${EROOT}/usr/${libdir} && ! -L ${EROOT}/usr/${libdir} ]] \
			&& iface_do_list $libdir
	done
}

### set action

describe_set() {
	echo "Activate one of the installed $MODULE implementations"
}

describe_set_parameters() {
	echo "<implementation>"
}

describe_set_options() {
	echo "implementation : implementation name or number (from 'list' action)"
}

do_set() {
	[[ $# -eq 0 ]] && die -q "Please specify exactly 1 implementation!"
	local fail=0 iface=$IFACE
	local libdirs=$(get_libdirs)
	local libdir implem libdir_ct i=0
	local -a file implems new_implems mylibdirs myimplems

	# Build up list of all valid implems
	for libdir in ${libdirs}; do
		new_implems=( $(find_implems ${iface} ${libdir}) )
		implems=( ${implems[@]} ${new_implems[@]} )
		libdir_ct[$i]=${#new_implems[@]}
		(( i++ ))
	done

	# Parse passed parameters into valid libdirs. Other arguments are considered
	# implementations (or numbers for them) and are validated later.
	# If libdirs are specified, then switch for them. Otherwise, switch for all
	# libdirs.
	for param in ${@} ; do
		if has ${param} ${libdirs} ; then
			mylibdirs=(${mylibdirs[@]} ${param})
		else
			myimplems=(${myimplems[@]} ${param})
		fi
	done
	set ${myimplems[@]}

	# We can only change one implem at a time
	[[ ${#myimplems[@]} -ne 1 ]] && \
		die -q "Please specify exactly 1 implemention."

	[[ -n ${mylibdirs[@]} ]] && libdirs=${mylibdirs[@]}

	i=0
	for libdir in ${libdirs}; do
		# Only move on if we actually have implems here, otherwise we screw up
		# $libdir_max and waste time executing pointless code
		if [[ ${libdir_ct[$i]} -gt 0 ]]; then
			for item in ${@} ; do
				if is_number ${item} ; then
					# On the first libdir, minimum must be 1. Maxes and later
					# mins are incremented by the size of the previous libdir_ct
					if [[ -n ${libdir_min} ]]; then
						libdir_min=$(( ${libdir_min} + ${libdir_ct[$(( $i - 1 ))]} ))
					else
						libdir_min="1"
					fi
					libdir_max=$(( ${libdir_min} + ${libdir_ct[$i]} - 1 ))
					if [[ ${item} -ge ${libdir_min} ]] && [[ ${item} -le ${libdir_max} ]] ; then
						if ! switch_implem ${iface} ${libdir} ${implems[$(( ${item} -1 ))]}; then
							fail=1
							echo "Failed to switch to implementation \"${item}\" for library directory \"${libdir}\"!"
							continue
						fi
					else
						fail=1
						echo "Item not in range ${libdir_min}-${libdir_max} for ${libdir}: ${item}"
						continue
					fi
				else
					# Only attempt to switch to an implementation if it's available
					# for that libdir
					if has ${item} $(find_implems ${iface} ${libdir}); then
						if ! switch_implem ${iface} ${libdir} ${item}; then
							fail=1
							echo "Failed to switch to implementation \"${item}\" for library directory \"${libdir}\"!"
							continue
						fi
					fi
				fi
			done
		fi
		(( i++ ))
	done

	[[ ${fail} == 1 ]] && die -q "One or more actions have failed!"
}

### show action

describe_show() {
	echo "Print the currently active $MODULE implementation"
}

do_show() {
	local libdir
	local libdirs=$(get_libdirs)
	for param in ${@} ; do
		if has ${param} ${libdirs} ; then
			mylibdirs=(${mylibdirs[@]} ${param})
		fi
	done
	[[ -n ${mylibdirs[@]} ]] && libdirs=${mylibdirs[@]}

	for libdir in ${libdirs}; do
		[[ -d ${EROOT}/usr/${libdir} && ! -L ${EROOT}/usr/${libdir} ]] \
			&& iface_do_show $libdir
	done
}

### add action

describe_add() {
	echo "Add a new $MODULE implementation"
}

describe_add_parameters() {
	echo "<libdir> <file> <implementation>"
}

describe_add_options() {
	echo "libdir : library directory where $MODULE implementation is installed (lib, lib64, etc.)"
	echo "file : path to file containing symlink map"
	echo "implementation : name of the $MODULE implementation"
}

do_add() {
	[[ $# -eq 3 ]] \
		|| die -q "Please specify 1 library directory, 1 file to install and 1 implementation!"

	# If $D is set, we're adding from portage so we want to respect sandbox.
	# Otherwise, respect the ROOT variable.
	local prefix=${D:-${ROOT}}${EPREFIX}

	# Create directory if necessary
	if [[ ! -e ${prefix}/etc/env.d/${IFACE}/${1} ]]; then
		mkdir -p "${prefix}/etc/env.d/${IFACE}/${1}"
	elif [[ ! -d ${prefix}/etc/env.d/${IFACE}/${1} ]]; then
		die -q "${prefix}/etc/env.d/${IFACE}/${1} exists but isn't a directory!"
	fi

	if ! cp "${2}" "${prefix}/etc/env.d/${IFACE}/${1}/${3}"; then
		die -q "Installing ${2} as ${prefix}/etc/env.d/${IFACE}/${1}/${3} failed!"
	fi
}
