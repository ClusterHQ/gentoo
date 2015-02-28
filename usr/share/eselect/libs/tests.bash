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

# has test list
# Return true if list contains test
has() {
	local test=${1} item
	shift
	for item; do
		[[ ${item} == ${test} ]] && return 0
	done
	return 1
}

# is_function function PUBLIC
# Test whether function exists
is_function() {
	[[ $(type -t "${1}" ) == "function" ]]
}

# is_number PUBLIC
# Returns true if and only if $1 is a positive whole number
is_number() {
	[[ -n ${1} ]] && [[ -z ${1//[[:digit:]]} ]]
}
