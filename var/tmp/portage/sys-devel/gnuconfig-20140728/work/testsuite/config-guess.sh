#!/bin/sh
#
# Copyright 2004, 2005, 2009, 2012 Free Software Foundation, Inc.
# Contributed by Ben Elliston <bje@gnu.org>.
#
# This test reads 5-tuples from config-guess.data: the components of
# the simulated uname(1) output and the expected GNU system triplet.

verbose=false
PATH=`pwd`:$PATH

run_config_guess ()
{
    rc=0
    while read machine release system version triplet ; do
	sed \
	    -e "s,@MACHINE@,$machine," \
	    -e "s,@RELEASE@,$release," \
	    -e "s,@SYSTEM@,$system," \
	    -e "s,@VERSION@,$version," > uname << EOF
#!/bin/sh
[ \$# -ne 1 ] && exec sh \$0 -s
[ \$1 = -m ] && echo "@MACHINE@" && exit 0
[ \$1 = -r ] && echo "@RELEASE@" && exit 0
[ \$1 = -s ] && echo "@SYSTEM@" && exit 0
[ \$1 = -v ] && echo "@VERSION@" && exit 0
[ \$1 = -p ] && echo "Pentium III(TM)-ISA/PCI"
EOF
	chmod +x uname
	output=`sh ../config.guess 2>/dev/null`
	if test $? != 0 ; then
	    echo "FAIL: unable to guess $machine:$release:$system:$version"
	    rc=1
	    continue
	fi
	if test $output != $triplet ; then
	    echo "FAIL: $output (expected $triplet)"
	    rc=1
	    continue
	fi
	$verbose && echo "PASS: $triplet"
    done
    return $rc
}

if run_config_guess < config-guess.data ; then
  $verbose || echo "PASS: config.guess checks"
else
  echo "Unexpected failures."
  exit 1
fi

exit 0
