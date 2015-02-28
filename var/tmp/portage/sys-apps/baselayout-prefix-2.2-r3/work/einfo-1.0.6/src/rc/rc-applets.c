/*
  rc-applets.c

  Handle multicall applets for use in our init scripts.
  Basically this makes us a lot faster for the most part, and removes
  any shell incompatabilities we might otherwise encounter.
*/

/*
 * Copyright (c) 2007-2009 Roy Marples <roy@marples.name>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>

#include <errno.h>
#include <ctype.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include "helpers.h"
#include "einfo.h"

/* usecs to wait while we poll the file existance  */
#define WAIT_INTERVAL	20000000
#define ONE_SECOND      690000000

/* Applet is first parsed in rc.c - no point in doing it again */
extern const char *applet;

/* copied from rc-misc.h, only bit necessary */
_unused static bool exists(const char *pathname)
{
	struct stat buf;

	return (stat(pathname, &buf) == 0);
}

static int
do_e(int argc, char **argv)
{
	int retval = EXIT_SUCCESS;
	int i;
	size_t l = 0;
	char *message = NULL;
	char *p;
	int level = 0;
	struct timespec ts;
	struct timeval stop, now;
	int (*e) (const char *, ...) EINFO_PRINTF(1, 2) = NULL;
	int (*ee) (int, const char *, ...) EINFO_PRINTF(2, 3) = NULL;

	/* Punt applet */
	argc--;
	argv++;

	if (strcmp(applet, "eval_ecolors") == 0) {
		printf("GOOD='%s'\nWARN='%s'\nBAD='%s'\nHILITE='%s'\nBRACKET='%s'\nNORMAL='%s'\n",
		    ecolor(ECOLOR_GOOD),
		    ecolor(ECOLOR_WARN),
		    ecolor(ECOLOR_BAD),
		    ecolor(ECOLOR_HILITE),
		    ecolor(ECOLOR_BRACKET),
		    ecolor(ECOLOR_NORMAL));
		exit(EXIT_SUCCESS);
	}

	if (argc > 0) {
		if (strcmp(applet, "eend") == 0 ||
		    strcmp(applet, "ewend") == 0 ||
		    strcmp(applet, "veend") == 0 ||
		    strcmp(applet, "vweend") == 0 ||
		    strcmp(applet, "ewaitfile") == 0)
		{
			errno = 0;
			retval = (int)strtoimax(argv[0], &p, 0);
			if (!p || *p != '\0')
				errno = EINVAL;
			if (errno)
				retval = EXIT_FAILURE;
			else {
				argc--;
				argv++;
			}
		}
	}

	if (strcmp(applet, "ewaitfile") == 0) {
		if (errno)
			eerrorx("%s: invalid timeout", applet);
		if (argc == 0)
			eerrorx("%s: not enough arguments", applet);

		gettimeofday(&stop, NULL);
		/* retval stores the timeout */
		stop.tv_sec += retval;
		ts.tv_sec = 0;
		ts.tv_nsec = WAIT_INTERVAL;
		for (i = 0; i < argc; i++) {
			ebeginv("Waiting for %s", argv[i]);
			for (;;) {
				if (exists(argv[i]))
					break;
				if (nanosleep(&ts, NULL) == -1)
					return EXIT_FAILURE;
				gettimeofday(&now, NULL);
				if (retval <= 0)
					continue;
				if (timercmp(&now, &stop, <))
					continue;
				eendv(EXIT_FAILURE,
				    "timed out waiting for %s", argv[i]);
				return EXIT_FAILURE;
			}
			eendv(EXIT_SUCCESS, NULL);
		}
		return EXIT_SUCCESS;
	}

	if (argc > 0) {
		for (i = 0; i < argc; i++)
			l += strlen(argv[i]) + 1;

		message = xmalloc(l);
		p = message;

		for (i = 0; i < argc; i++) {
			if (i > 0)
				*p++ = ' ';
			l = strlen(argv[i]);
			memcpy(p, argv[i], l);
			p += l;
		}
		*p = 0;
	}

	if (strcmp(applet, "einfo") == 0)
		e = einfo;
	else if (strcmp(applet, "einfon") == 0)
		e = einfon;
	else if (strcmp(applet, "ewarn") == 0)
		e = ewarn;
	else if (strcmp(applet, "ewarnn") == 0)
		e = ewarnn;
	else if (strcmp(applet, "eerror") == 0) {
		e = eerror;
		retval = 1;
	} else if (strcmp(applet, "eerrorn") == 0) {
		e = eerrorn;
		retval = 1;
	} else if (strcmp(applet, "ebegin") == 0)
		e = ebegin;
	else if (strcmp(applet, "eend") == 0)
		ee = eend;
	else if (strcmp(applet, "ewend") == 0)
		ee = ewend;
	else if (strcmp(applet, "esyslog") == 0) {
		elog(retval, "%s", message);
		retval = 0;
	} else if (strcmp(applet, "veinfo") == 0)
		e = einfov;
	else if (strcmp(applet, "veinfon") == 0)
		e = einfovn;
	else if (strcmp(applet, "vewarn") == 0)
		e = ewarnv;
	else if (strcmp(applet, "vewarnn") == 0)
		e = ewarnvn;
	else if (strcmp(applet, "vebegin") == 0)
		e = ebeginv;
	else if (strcmp(applet, "veend") == 0)
		ee = eendv;
	else if (strcmp(applet, "vewend") == 0)
		ee = ewendv;
	else if (strcmp(applet, "eindent") == 0)
		eindent();
	else if (strcmp(applet, "eoutdent") == 0)
		eoutdent();
	else if (strcmp(applet, "veindent") == 0)
		eindentv();
	else if (strcmp(applet, "veoutdent") == 0)
		eoutdentv();
	else {
		eerror("%s: unknown applet", applet);
		retval = EXIT_FAILURE;
	}

	if (message) {
		if (e)
			e("%s", message);
		else if (ee)
			ee(retval, "%s", message);
	} else {
		if (e)
			e(NULL);
		else if (ee)
			ee(retval, NULL);
	}

	free(message);
	return retval;
}

void
run_applets(int argc, char **argv)
{
	size_t i;

	/* Bug 351712: We need an extra way to explicitly select an applet OTHER
	 * than trusting argv[0], as argv[0] is not going to be the applet value if
	 * we are doing SELinux context switching. For this, we allow calls such as
	 * 'rc --applet APPLET', and shift ALL of argv down by two array items. */
	if (strcmp(applet, "rc") == 0 && argc >= 3 &&
		(strcmp(argv[1],"--applet") == 0 || strcmp(argv[1], "-a") == 0)) {
		applet = argv[2];
		argv += 2;
		argc -= 2;
	}

	if (applet[0] == 'e' || (applet[0] == 'v' && applet[1] == 'e'))
		exit(do_e(argc, argv));

	if (strcmp(applet, "rc") != 0)
		eerrorx("%s: unknown applet", applet);
}
