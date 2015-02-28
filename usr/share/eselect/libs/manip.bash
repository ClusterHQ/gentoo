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

# svn_date_to_version PUBLIC
# Turn an SVN or CVS date string into a nice version number, for those
# of us who are too lazy to manually update VERSION in modules. Safe to
# use in global scope.
svn_date_to_version() {
	local s=${1}
	s=${s#* }
	s=${s%% *}
	echo "${s//[-\/]}"
}
