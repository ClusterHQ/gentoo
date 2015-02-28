/*
 * Copyright 2008-2012 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * Authors: Michael Haubenwallner <haubi@gentoo.org>
 */

#ifndef _TEXTFILE_H_
#define _TEXTFILE_H_

#include <stringutil.h>

typedef struct _Textfile Textfile;

extern String const* TextfileGetCurrentLine(Textfile* textfile);
extern StringList const* TextfileGetLines(Textfile* textfile);
extern Textfile* TextfileClose(Textfile* textfile);
extern Textfile* TextfileOpenConcatName(char const *filename, int filenamelen, ...);

extern int TextfileReadLine(Textfile* textfile);
extern int TextfileReadLines(Textfile* textfile);

#endif /* _TEXTFILE_H_ */
