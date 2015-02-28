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

colours() {
	if [[ $1 != n* ]]; then
		COLOUR_NORMAL=$(tput sgr0)
		COLOUR_BOLD=$(tput bold)
		COLOUR_HI=$(tput setaf 4)${COLOUR_BOLD} # blue
		COLOUR_WARN=$(tput setaf 1)${COLOUR_BOLD} # red
		COLOUR_ERROR=${COLOUR_WARN}
		COLOUR_LIST_HEADER=$(tput setaf 2)${COLOUR_BOLD} # green
		COLOUR_LIST_LEFT=${COLOUR_BOLD}
		COLOUR_LIST_RIGHT=${COLOUR_NORMAL}
	else
		# disable all colours
		COLOUR_NORMAL=""
		COLOUR_BOLD=""
		COLOUR_HI=""
		COLOUR_WARN=""
		COLOUR_ERROR=""
		COLOUR_LIST_HEADER=""
		COLOUR_LIST_LEFT=""
		COLOUR_LIST_RIGHT=""
	fi
}

# set output mode to $1
set_output_mode() {
	ESELECT_OUTPUT_MODE=$1
}

# is_output_mode PUBLIC
# test if $1 is the current output mode
is_output_mode() {
	[[ ${ESELECT_OUTPUT_MODE} = $1 ]]
}

# Determine width of terminal and set COLUMNS variable
init_columns() {
	[[ -n ${COLUMNS} ]] || COLUMNS=$(tput cols) || COLUMNS=80
}

# write_error_msg PUBLIC
# write an error
write_error_msg() {
	echo -e "${COLOUR_ERROR}!!! Error: ${COLOUR_NORMAL}${*}" 1>&2
}

# write_warning_msg PUBLIC
# write a warning
write_warning_msg() {
	echo -e "${COLOUR_WARN}!!! Warning: ${COLOUR_NORMAL}${*}" 1>&2
}

# write_list_start PUBLIC
# Write a list heading. Args may include text highlighting. If -p is passed,
# use 'plain' highlighting.
write_list_start() {
	is_output_mode brief && return
	local colour=${COLOUR_LIST_HEADER} normal=${COLOUR_NORMAL}
	if [[ $1 == "-p" ]]; then
		colour=; normal=
		shift
	fi
	echo -n -e "${colour}"
	echo -n -e "$(apply_text_highlights "${colour}" "$*")"
	echo -n -e "${normal}"
	echo
}

# write_kv_list_entry PUBLIC
# Write a key/value list entry with $1 on the left and $2 on the right.
# Args may include text highlighting. If -p is passed, use 'plain'
# highlighting rather than bold.
write_kv_list_entry() {
	local n text key val lindent rindent
	local left=${COLOUR_LIST_LEFT} right=${COLOUR_LIST_RIGHT}
	local normal=${COLOUR_NORMAL}
	local cols=${COLUMNS:-80}
	local IFS=$' \t\n'

	if [[ $1 == "-p" ]]; then
		left=; right=; normal=
		shift
	fi

	lindent=${1%%[^[:space:]]*}
	rindent=${2%%[^[:space:]]*}
	key=${1##*([[:space:]])}
	val=${2##*([[:space:]])}

	echo -n -e "  ${lindent}${left}"
	echo -n -e "$(apply_text_highlights "${left}" "${key}")"
	echo -n -e "${normal}"

	text=${key//\%%%??%%%/}
	n=$(( 26 + ${#rindent} - ${#lindent} - ${#text} ))

	text=${val//\%%%??%%%/}
	if [[ -z ${text} ]]; then
		# empty ${val}: end the line and be done
		echo
		return
	fi

	# if ${n} is less than or equal to zero then we have a long ${key}
	# that will mess up the formatting of ${val}, so end the line, indent
	# and let ${val} go on the next line. Don't start a new line when
	# in brief output mode, in order to keep the output easily parsable.
	if [[ ${n} -le 0 ]]; then
		if is_output_mode brief; then
			n=1
		else
			echo
			n=$(( 28 + ${#rindent} ))
		fi
	fi

	echo -n -e "$(space ${n})${right}"
	n=$(( 28 + ${#rindent} ))

	# only loop if it doesn't fit on the same line
	if [[ $(( ${n} + ${#text} )) -ge ${cols} ]] && ! is_output_mode brief; then
		local i=0 spc=""
		rindent=$(space ${n})
		local cwords=( $(apply_text_highlights "${right}" "${val}") )
		for text in ${val}; do
			text=${text//\%%%??%%%/}
			# put the word on the same line if it fits
			if [[ $(( ${n} + ${#spc} + ${#text} )) -lt ${cols} ]]; then
				echo -n -e "${spc}${cwords[i]}"
				n=$(( ${n} + ${#spc} + ${#text} ))
			# otherwise, start a new line and indent
			else
				echo -n -e "\n${rindent}${cwords[i]}"
				n=$(( ${#rindent} + ${#text} ))
			fi
			(( i++ ))
			spc=" "
		done
	else
		echo -n -e "$(apply_text_highlights "${right}" "${val}")"
	fi
	echo -e "${normal}"
}

# write_numbered_list_entry PUBLIC
# Write out a numbered list entry with index $1 and text $2. Args may
# include text highlighting. If -p is passed, use 'plain' highlighting.
write_numbered_list_entry() {
	local left=${COLOUR_LIST_LEFT} right=${COLOUR_LIST_RIGHT}
	local normal=${COLOUR_NORMAL}

	if [[ $1 == "-p" ]]; then
		left=; right=; normal=
		shift
	fi

	if ! is_output_mode brief; then
		echo -n -e "  ${left}"
		echo -n -e "[$(apply_text_highlights "${left}" "$1")]"
		echo -n -e "${normal}"
		space $(( 4 - ${#1} ))
	fi

	echo -n -e "${right}"
	echo -n -e "$(apply_text_highlights "${right}" "$2")"
	echo -e "${normal}"
}

# write_numbered_list PUBLIC
# Write out a numbered list. Args may include text highlighting.
# If called with the -m option and an empty list, output a negative report.
write_numbered_list() {
	local n=1 m p
	while [[ $1 == -* ]]; do
		case $1 in
			"-m") shift; m=$1 ;;
			"-p") p="-p" ;;
			"--") shift; break ;;
		esac
		shift
	done

	if [[ $# -eq 0 && -n ${m} ]] && ! is_output_mode brief; then
		write_kv_list_entry ${p} "${m}" ""
	fi

	while [[ $# -gt 0 ]]; do
		item=$1
		shift
		if [[ ${item##*\\} == "" ]]; then
			item="${item%\\} $1"
			shift
		fi
		write_numbered_list_entry ${p} "${n}" "${item}"
		n=$(( ${n} + 1 ))
	done
}

# apply_text_highlights INTERNAL
# Apply text highlights. First arg is the 'restore' colour, second arg
# is the text.
apply_text_highlights() {
	local restore=${1:-${COLOUR_NORMAL}} text=$2
	text="${text//?%%HI%%%/${COLOUR_HI}}"
	text="${text//?%%WA%%%/${COLOUR_WARN}}"
	text="${text//?%%RE%%%/${restore}}"
	echo -n "${text}"
}

# highlight PUBLIC
# Highlight all arguments. Text highlighting function.
highlight() {
	echo -n "%%%HI%%%${*}%%%RE%%%"
}

# highlight_warning PUBLIC
# Highlight all arguments as a warning (red). Text highlighting function.
highlight_warning() {
	echo -n "%%%WA%%%${*}%%%RE%%%"
}

# highlight_marker PUBLIC
# Mark list entry $1 as active/selected by placing a highlighted star
# (or $2 if set) behind it.
highlight_marker() {
	local text=$1 mark=${2-*}
	echo -n "${text}"
	if [[ -n ${mark} ]] && ! is_output_mode brief; then
		echo -n " "
		highlight "${mark}"
	fi
}

# space PUBLIC
# Write $1 numbers of spaces
space() {
	local n=$1
	while (( n-- > 0 )); do
		echo -n " "
	done
}
