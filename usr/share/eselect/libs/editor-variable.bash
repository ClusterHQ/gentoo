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

# This library is for managing environment variables like EDITOR or PAGER.
# To use it, you must set the following variables:
#
# EDITOR_VAR is the name of the environment variable, e.g. "EDITOR".
# EDITOR_ENVFILE is the path to the config file where the variable should be
# stored, e.g. "/etc/env.d/99editor". Several modules may share the same file.
# EDITOR_LIST is a space-separated list of available programs (full pathnames)
# e.g. "/bin/nano /usr/bin/emacs /usr/bin/vi". Alternatively, items can be of
# the form "name:/path/to/binary".
# EDITOR_PATH (optional) is a colon-separated list of directories where to
# search for available programs. Default is "/bin:/usr/bin".

inherit config

# find a list of valid targets
find_targets() {
	local cur i

	for i in ${EDITOR_LIST}; do
		[[ -f ${EROOT}${i#*:} ]] && echo "${EPREFIX}${i%%:*}"
	done

	# also output the current value if it isn't in our list
	cur=$(read_env_value)
	[[ -n ${cur} && ${EDITOR_LIST} != *:* && -f ${ROOT}${cur} ]] \
		&& ! has "${cur#${EPREFIX}}" ${EDITOR_LIST} \
		&& echo "${cur}"
}

# read variable value from config file
read_env_value() {
	load_config "${EROOT}${EDITOR_ENVFILE}" "${EDITOR_VAR}"
}

# write variable to config file
write_env_value() {
	[[ -w ${EROOT}${EDITOR_ENVFILE%/*} ]] \
		|| die -q "You need root privileges!"
	store_config "${EROOT}${EDITOR_ENVFILE}" "${EDITOR_VAR}" "$1"
}

### show action ###

describe_show() {
	echo "Show value of the ${EDITOR_VAR} variable in profile"
}

do_show() {
	[[ $# -gt 0 ]] && die -q "Too many parameters"

	local cur=$(read_env_value)
	write_list_start "${EDITOR_VAR} variable in profile:"
	write_kv_list_entry "${cur:-(none)}"
}

### list action ###

describe_list() {
	echo "List available targets for the ${EDITOR_VAR} variable"
}

do_list() {
	[[ $# -gt 0 ]] && die -q "Too many parameters"

	local cur targets i
	cur=$(read_env_value)
	targets=( $(find_targets) )

	write_list_start "Available targets for the ${EDITOR_VAR} variable:"
	for (( i = 0; i < ${#targets[@]}; i = i + 1 )); do
		targets[i]=${targets[i]%%:*}
		# display a star to indicate the currently chosen version
		[[ ${targets[i]} = "${cur}" ]] \
			&& targets[i]=$(highlight_marker "${targets[i]}")
	done
	write_numbered_list "${targets[@]}"

	if is_output_mode brief; then
		:
	elif [[ ${EDITOR_LIST} != *:* ]]; then
		write_numbered_list_entry " " "(free form)"
	elif [[ ${#targets[@]} -eq 0 ]]; then
		write_kv_list_entry "(none found)" ""
	fi
}

### set action ###

describe_set() {
	echo "Set the ${EDITOR_VAR} variable in profile"
}

describe_set_options() {
	echo "target : Target name or number (from 'list' action)"
}

describe_set_parameters() {
	echo "<target>"
}

do_set() {
	[[ -z $1 ]] && die -q "You didn't tell me what to set the variable to"
	[[ $# -gt 1 ]] && die -q "Too many parameters"

	local target=$1 targets=() dir

	# target may be specified by its name or its index
	if is_number "${target}"; then
		targets=( $(find_targets) )
		[[ ${target} -ge 1 && ${target} -le ${#targets[@]} ]] \
			|| die -q "Number out of range: $1"
		target=${targets[target-1]%%:*}
	fi

	if [[ ${EDITOR_LIST} != *:* ]]; then
		# is the target an absolute path? if not, try to find it
		if [[ ${target} != /* ]]; then
			local ifs_save=${IFS} IFS=:
			for dir in ${EDITOR_PATH-/bin:/usr/bin}; do
				[[ -f ${EROOT}${dir}/${target} ]] || continue
				target=${EPREFIX}${dir}/${target}
				break
			done
			IFS=${ifs_save}
		fi
		# target is valid if it's a path to an existing binary
		[[ ${target} == /* && -f ${ROOT}${target} ]] \
			|| die -q "Target \"${target}\" doesn't appear to be valid!"
	else
		# target is valid only if it's in our list
		[[ ${#targets[@]} -gt 0 ]] || targets=( $(find_targets) )
		has "${target}" "${targets[@]%%:*}" \
			|| die -q "Target \"${target}\" doesn't appear to be valid!"
	fi

	echo "Setting ${EDITOR_VAR} to ${target} ..."
	write_env_value "${target}"

	# update profile
	do_action env update noldconfig
	if [[ ${ROOT:-/} = / ]]; then
		echo "Run \". ${EROOT}/etc/profile\" to update the variable" \
			"in your shell."
	fi
}

### update action ###

describe_update() {
	echo "Update the ${EDITOR_VAR} variable if it is unset or invalid"
}

do_update() {
	[[ $# -gt 0 ]] && die -q "Too many parameters"

	local cur targets
	cur=$(read_env_value)

	[[ ${EDITOR_LIST} != *:* && ${cur} == /* && -f ${ROOT}${cur} ]] && return

	targets=( $(find_targets) )
	[[ ${#targets[@]} -gt 0 ]] \
		|| die -q "No valid target for ${EDITOR_VAR} found"

	has "${cur}" "${targets[@]%%:*}" && return

	echo "Setting ${EDITOR_VAR} to ${targets[0]%%:*} ..."
	write_env_value "${targets[0]%%:*}"

	do_action env update noldconfig
}
