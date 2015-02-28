/*
 * Copyright 2008-2012 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * Authors: Michael Haubenwallner <haubi@gentoo.org>
 */

#include <stdio.h> /* fopen,fclose,fgetpos,fsetpos */
#include <stdlib.h> /* malloc,free */
#include <errno.h> /* errno */
#include <string.h> /* strlen */
#include <sys/param.h> /* MAXPATHLEN */

#include "textfile.h"

#define MAXLINELEN (MAXPATHLEN*2) /* may contain blanks, string-delimiters, whatever */

struct _Textfile {
	String* filename_;
	FILE*	filehandle_;
	String* currentline_;
	StringList* alllines_;
};

/* returns: current line of Textfile, set up by TextfileReadLine() */
String const* TextfileGetCurrentLine(Textfile* textfile)
{
	if (textfile == NULL) {
		return NULL;
	}
	return textfile->currentline_;
}

/* returns: all lines of Textfile, set up by TextfileReadLines() */
StringList const* TextfileGetLines(Textfile* textfile)
{
	if (textfile == NULL) {
		return NULL;
	}
	return textfile->alllines_;
}

/* close Textfile and free the resources.
 * returns: NULL
 */
Textfile* TextfileClose(Textfile* textfile)
{
	if (textfile == NULL) {
		return NULL;
	}
	if (textfile->filehandle_ != NULL) {
		fclose(textfile->filehandle_);
		textfile->filehandle_ = NULL;
	}
	textfile->filename_ = StringDestroy(textfile->filename_);
	free(textfile);
	return NULL;
}

/* open Textfile with filename created from arguments.
 * returns: NULL on error, with errno set.
 * returns: Handle of Textfile, file already opened.
 */
Textfile* TextfileOpenConcatName(char const *filename, int filenamelen, ...)
{
	va_list args;
	Textfile* textfile = (Textfile*)malloc(sizeof(Textfile));
	if (textfile == NULL) {
		return NULL;
	}
	va_start(args, filenamelen);
	textfile->filename_ = StringCreateVaConcat(filename, filenamelen, args);
	va_end(args);
	if (textfile->filename_ == NULL) {
		textfile = TextfileClose(textfile);
		return NULL;
	}
	textfile->filehandle_ = fopen(StringGetBuffer(textfile->filename_), "r");
	if (textfile->filehandle_ == NULL) {
		textfile = TextfileClose(textfile);
		return NULL;
	}
	textfile->currentline_ = NULL;
	textfile->alllines_ = NULL;
	return textfile;
}

/* read one line from current position in Textfile into internal one-line buffer.
 * returns: -1 on any error with errno set, file-position restored (untouched).
 * returns:  0 on no more lines (end of file), internal one-line buffer destroyed.
 * returns:  1 on success, internal one-line buffer containing current line,
 *             file-position at next line.
 */
int TextfileReadLine(Textfile* textfile)
{
	char linebuf[MAXLINELEN+1];
	int linelen;
	int rv = 0;
	char longline;
	fpos_t save_fpos;
	int save_errno;
	String* thisline = NULL;

	if (textfile == NULL) {
		errno = EINVAL;
		return -1;
	}

	if (fgetpos(textfile->filehandle_, &save_fpos) != 0) {
		return -1;
	}

	linebuf[MAXLINELEN] = '\0';
	while(fgets(linebuf, sizeof(linebuf), textfile->filehandle_) != NULL) {
		linelen = strlen(linebuf);
		if (linebuf[linelen-1] == '\n') {
			linelen--; /* kill trailing newline */
			longline = 0;
		} else {
			longline = 1;
		}
		if (thisline == NULL) {
			thisline = StringCreateConcat(linebuf, linelen, NULL);
			if (thisline == NULL) {
				rv = -1;
				break;
			}
		} else {
			if (StringAppendConcat(thisline, linebuf, linelen, NULL) < 0) {
				rv = -1;
				break;
			}
		}
		if (longline == 0) {
			/* end of line seen */
			rv = 1;
			break;
		}
	}
	if (rv < 0) {
		save_errno = errno;
		thisline = StringDestroy(thisline);
		/* restore file position if possible, and report original errno */
		fsetpos(textfile->filehandle_, &save_fpos);
		errno = save_errno;
		return rv;
	}

	StringDestroy(textfile->currentline_);
	textfile->currentline_ = thisline;

	return rv;
}

/* read all remaining lines of Textfile and store the String's in internal all-lines buffer.
 * returns: -1 on error, with errno set, internal cu
 * returns: number of lines read from file.
 */
int TextfileReadLines(Textfile* textfile)
{
	int rv = 0;
	fpos_t save_fpos;
	int save_errno;
	String* save_currentline = NULL;
	StringList *lines;

	if (textfile == NULL) {
		errno = EINVAL;
		return -1;
	}

	if (fgetpos(textfile->filehandle_, &save_fpos) != 0) {
		return -1;
	}

	lines = StringListCreate(NULL, 0, 0);
	if (lines == NULL) {
		return -1;
	}

	save_currentline = textfile->currentline_;
	textfile->currentline_ = NULL;

	while(TextfileReadLine(textfile) > 0) {
		if (StringListAppendString(lines, textfile->currentline_) < 0) {
			rv = -1;
			break;
		}
		rv ++;
	}

	if (rv < 0) {
		StringDestroy(textfile->currentline_);
		textfile->currentline_ = save_currentline;
		save_errno = errno;
		fsetpos(textfile->filehandle_, &save_fpos);
		errno = save_errno;
		return rv;
	}

	StringListDestroy(textfile->alllines_);
	textfile->alllines_ = lines;

	StringDestroy(save_currentline);

	return rv;
}

