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

# basename and dirname functions
# transparent bash-only replacements for the external commands
# extended pattern matching (shopt -s extglob) is required
basename() {
	local path=$1 suf=$2

	if [[ -z ${path} ]]; then
		echo
		return
	fi

	# remove any trailing slashes
	path=${path%%*(/)}

	# remove everything up to and including the last slash
	path=${path##*/}

	# remove any suffix
	[[ ${suf} != "${path}" ]] && path=${path%"${suf}"}

	# output the result, or "/" if we ended up with a null string
	echo "${path:-/}"
}

dirname() {
	local path=$1

	if [[ -z ${path} ]]; then
		echo .
		return
	fi

	# remove any trailing slashes
	path=${path%%*(/)}

	# if the path contains only non-slash characters, then dirname is cwd
	[[ ${path:-/} != */* ]] && path=.

	# remove any trailing slashes followed by non-slash characters
	path=${path%/*}
	path=${path%%*(/)}

	# output the result, or "/" if we ended up with a null string
	echo "${path:-/}"
}

# Wrapper function for either GNU "readlink -f" or "realpath".
canonicalise() {
	/home/core/gentoo/usr/bin/readlink -f "$@"
}

# relative_name
# Convert filename $1 to be relative to directory $2.
# For both paths, all but the last component must exist.
relative_name() {
	local path=$(canonicalise "$1") dir=$(canonicalise "$2") c
	while [[ -n ${dir} ]]; do
		c=${dir%%/*}
		dir=${dir##"${c}"*(/)}
		if [[ ${path%%/*} = "${c}" ]]; then
			path=${path##"${c}"*(/)}
		else
			path=..${path:+/}${path}
		fi
	done
	echo "${path:-.}"
}
