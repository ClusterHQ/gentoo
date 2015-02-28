#!/bin/bash

source tests-common.sh

inherit eutils

test-path_exists() {
	local exp=$1; shift
	tbegin "path_exists($*) == ${exp}"
	path_exists "$@"
	[[ ${exp} -eq $? ]]
	tend $?
}

test-path_exists 1
test-path_exists 1 -a
test-path_exists 1 -o

good="/ . tests-common.sh /bin/bash"
test-path_exists 0 ${good}
test-path_exists 0 -a ${good}
test-path_exists 0 -o ${good}

bad="/asjdkfljasdlfkja jlakjdsflkasjdflkasdjflkasdjflaskdjf"
test-path_exists 1 ${bad}
test-path_exists 1 -a ${bad}
test-path_exists 1 -o ${bad}

test-path_exists 1 ${good} ${bad}
test-path_exists 1 -a ${good} ${bad}
test-path_exists 0 -o ${good} ${bad}

texit
