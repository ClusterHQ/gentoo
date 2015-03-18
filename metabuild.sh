#!/bin/bash -xe

# this file should be distributed separately from the repo...

git clone https://github.com/clusterhq/gentoo
gentoo/startprefix gentoo/build.sh
gentoo/startprefix sudo modprobe -d ~/gentoo zfs
