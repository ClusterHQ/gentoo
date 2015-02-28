# Copyright 2012-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

import io
import re
import subprocess
import sys

try:
	from configparser import Error as ConfigParserError, RawConfigParser
except ImportError:
	from ConfigParser import Error as ConfigParserError, RawConfigParser

import portage
from portage import _encodings, _unicode_encode, _unicode_decode
from portage.util import writemsg

def parse_desktop_entry(path):
	"""
	Parse the given file with RawConfigParser and return the
	result. This may raise an IOError from io.open(), or a
	ParsingError from RawConfigParser.
	"""
	parser = RawConfigParser()

	# use read_file/readfp in order to control decoding of unicode
	try:
		# Python >=3.2
		read_file = parser.read_file
	except AttributeError:
		read_file = parser.readfp

	with io.open(_unicode_encode(path,
		encoding=_encodings['fs'], errors='strict'),
		mode='r', encoding=_encodings['repo.content'],
		errors='replace') as f:
		content = f.read()

	# In Python 3.2, read_file does not support bytes in file names
	# (see bug #429544), so use StringIO to hide the file name.
	read_file(io.StringIO(content))

	return parser

_trivial_warnings = re.compile(r' looks redundant with value ')

_ignored_errors = (
		# Ignore error for emacs.desktop:
		# https://bugs.freedesktop.org/show_bug.cgi?id=35844#c6
		'error: (will be fatal in the future): value "TextEditor" in key "Categories" in group "Desktop Entry" requires another category to be present among the following categories: Utility',
		'warning: key "Encoding" in group "Desktop Entry" is deprecated'
)

_ShowIn_exemptions = (
	# See bug #480586.
	'contains an unregistered value "Pantheon"',
)

def validate_desktop_entry(path):
	args = ["desktop-file-validate", path]

	if sys.hexversion < 0x3020000 and sys.hexversion >= 0x3000000:
		# Python 3.1 _execvp throws TypeError for non-absolute executable
		# path passed as bytes (see http://bugs.python.org/issue8513).
		fullname = portage.process.find_binary(args[0])
		if fullname is None:
			raise portage.exception.CommandNotFound(args[0])
		args[0] = fullname

	args = [_unicode_encode(x, errors='strict') for x in args]
	proc = subprocess.Popen(args,
		stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
	output_lines = _unicode_decode(proc.communicate()[0]).splitlines()
	proc.wait()

	if output_lines:
		filtered_output = []
		for line in output_lines:
			msg = line[len(path)+2:]
			# "hint:" output is new in desktop-file-utils-0.21
			if msg.startswith('hint: ') or msg in _ignored_errors:
				continue
			if 'for key "NotShowIn" in group "Desktop Entry"' in msg or \
				'for key "OnlyShowIn" in group "Desktop Entry"' in msg:
				exempt = False
				for s in _ShowIn_exemptions:
					if s in msg:
						exempt = True
						break
				if exempt:
					continue
			filtered_output.append(line)
		output_lines = filtered_output

	if output_lines:
		output_lines = [line for line in output_lines
			if _trivial_warnings.search(line) is None]

	return output_lines

if __name__ == "__main__":
	for arg in sys.argv[1:]:
		for line in validate_desktop_entry(arg):
			writemsg(line + "\n", noiselevel=-1)
