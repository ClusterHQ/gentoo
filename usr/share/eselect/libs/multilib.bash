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

ES_VALID_MULTILIB_DIRS="lib lib32 lib64 libx32"

# list_libdirs PUBLIC
# Returns a space separated list of libdirs available on this machine
list_libdirs() {
	local dir
	local -a libdirs

	for dir in ${ES_VALID_MULTILIB_DIRS}; do
		[[ -d ${EROOT}/${dir} ]] && libdirs[${#libdirs[@]}]=${dir}
	done
	echo "${libdirs[@]}"
}
