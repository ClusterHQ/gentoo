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

# store_config file key value PUBLIC
# Stores a $key/$value pair for given module in $configfile
store_config() {
	# we need at least "module" and "key"
	[[ ${#@} -ge 2 ]] || die
	local configfile=${1} key=${2} value content vars line="" changed=0
	shift 2
	value=${@}

	if [[ ! -e ${configfile} ]] ; then
		mkdir -p ${configfile%/*} \
			|| die -q \
			"Couldn't create directory ${configfile%/*}"
	fi

	store_config_header() {
		echo "# Configuration file for eselect" \
			> ${configfile}
		echo "# This file has been automatically generated." \
			>> ${configfile}
	}

	if [[ ! -f ${configfile} ]] ; then
		store_config_header
		echo "${key}=\"${value}\"" \
			>> ${configfile}
		return
	fi

	content=$(<${configfile})

	if [[ -z ${content} ]] ; then
		store_config_header
		echo "${key}=\"${value}\"" \
			>> ${configfile}
		return
	fi

	(
		# parse the names of all settings in the file
		local ifs_save=${IFS} IFS=$'\n'
		for line in ${content} ; do
			[[ ${line/=/} != ${line} ]] || continue
			line=${line/=*/}
			local ${line}=""
			vars=(${vars[@]} ${line})
		done
		IFS=${ifs_save}

		source ${configfile} 2>&1 > /dev/null \
			|| die "Failed to source ${configfile}."

		store_config_header
		for var in ${vars[@]} ; do
			if [[ ${var} == ${key} ]] ; then
				echo "${var}=\"${value}\"" \
					>> ${configfile}
				changed=1
			else
				echo "${var}=\"${!var}\"" \
					>> ${configfile}
			fi
		done
		[[ ${changed} == 1 ]] \
			|| echo "${key}=\"${value}\"" \
			>> ${configfile}
	)
}

# load_config module key PUBLIC
# Loads $key value from $configfile
load_config() {
	[[ ${#@} -eq 2 ]] || die
	local configfile key value

	configfile=${1}
	key=${2}
	[[ ! -e ${configfile} ]] \
		&& return 1
	value=$(
		unset ${key}
		source ${configfile} 1>&2 > /dev/null \
			|| die "Failed to source ${configfile}."
		echo "${!key}"
	)
	echo "${value}"
}

# append_config file key item ... PUBLIC
# Appends $item to already stored value of $key in $configfile
# if $item is not already part of $key
append_config() {
	[[ ${#@} -gt 2 ]] || die
	local configfile=${1} key=${2} item oldvalue newvalue
	shift 2
	item="$@"
	oldvalue=$(load_config ${configfile} ${key})
	if ! has ${item} ${oldvalue[@]} ; then
		newvalue=( ${oldvalue[@]} ${item} )
		store_config ${configfile} ${key} ${newvalue[@]}
	fi
}
