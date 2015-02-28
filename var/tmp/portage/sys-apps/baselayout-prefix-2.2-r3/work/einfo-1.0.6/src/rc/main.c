/*
 * Written by Fabian Groffen
 * Placed in the Public Domain
 */


/* This file is a simple wrapper for rc-applets, which in turn is a
 * wrapper around libeinfo's functions */

#include <string.h>

const char *applet = NULL;

int
main(int argc, char *argv[])
{
	const char *p = NULL;

	/* find our name */
	if ((p = strrchr(argv[0], '/')) != NULL) {
		applet = p + 1;
	} else {
		applet = argv[0];
	}

	run_applets(argc, argv);
	return 0;
}
