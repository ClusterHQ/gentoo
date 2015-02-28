# -*-eselect-*-  vim: ft=eselect
# Copyright (c) 2005-2014 Gentoo Foundation
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

# check_do function args
# Check that function exists, and call it with args.
check_do() {
	local function=$1
	shift
	if is_function "${function}" ; then
		${function} "$@"
	else
		die "No function ${function}"
	fi
}

# die [-q] "Message" PUBLIC
# Display "Message" as an error. If -q is not provided, gives a stacktrace.
die() {
	local item funcname="" sourcefile="" lineno="" n e s="yes"

	# Restore stderr
	[[ -n ${ESELECT_STDERR} ]] && exec 2>&${ESELECT_STDERR}

	# do we have a working write_error_msg?
	if is_function "write_error_msg"; then
		e="write_error_msg"
	else
		e="echo"
	fi

	# quiet?
	if [[ $1 == "-q" ]]; then
		s=""
		shift
	fi

	$e "${@:-(no message)}" >&2

	if [[ -n ${s} ]]; then
		echo "Call stack:" >&2
		for (( n = 1; n < ${#FUNCNAME[@]}; ++n )); do
			funcname=${FUNCNAME[n]}
			sourcefile=$(basename ${BASH_SOURCE[n]})
			lineno=${BASH_LINENO[n-1]}
			echo "    * ${funcname} (${sourcefile}:${lineno})" >&2
		done
	fi

	# Evil, but effective.
	kill ${ESELECT_KILL_TARGET}
	exit 249
}

# find_module module PRIVATE
# Find module and echo its filename. Die if module doesn't exist.
find_module() {
	local modname=$1 modpath
	for modpath in "${ESELECT_MODULES_PATH[@]}"; do
		if [[ -f ${modpath}/${modname}.eselect ]]; then
			echo "${modpath}/${modname}.eselect"
			return
		fi
	done
	die -q "Can't load module ${modname}"
}

# do_action action args...
# Load and do 'action' with the specified args
do_action() {
	local action="${1##--}" modfile="" subaction="${2##--}"
	[[ -z ${action} ]] && die "Usage: do_action <action> <args>"
	shift; shift

	ESELECT_MODULE_NAME="${action}"
	ESELECT_COMMAND="${ESELECT_PROGRAM_NAME} ${ESELECT_MODULE_NAME}"

	[[ ${ESELECT_BINARY_NAME##*/} != "${ESELECT_PROGRAM_NAME}" ]] \
		&& ESELECT_COMMAND="${ESELECT_BINARY_NAME##*/}"

	modfile=$(find_module "${action}")
	(
		source "$ESELECT_DEFAULT_ACTIONS" 2>/dev/null \
			|| die "Couldn't source ${ESELECT_DEFAULT_ACTIONS}"
		source "${modfile}" 2>/dev/null \
			|| die "Couldn't source ${modfile}"
		if [[ -z ${subaction} ]]; then
			check_do "do_${DEFAULT_ACTION:-usage}" "$@"
		else
			is_function "do_${subaction}" \
				|| die -q "Action ${subaction} unknown"
			check_do "do_${subaction}" "$@"
		fi
	)
}

# inherit module PUBLIC
# Sources a given eselect library file
inherit() {
	local x
	for x; do
		[[ -e ${ESELECT_CORE_PATH}/${x}.bash ]] \
			|| die "Couldn't find ${x}.bash"
		source "${ESELECT_CORE_PATH}/${x}.bash" \
			|| die "Couldn't source ${x}.bash"
	done
}

# GNU sed wrapper (real path to GNU sed determined by configure)
sed() {
	/home/core/gentoo/bin/sed "$@"
}
