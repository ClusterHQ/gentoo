#!/bin/bash
set -x -e

# this file should be distributed separately from the repo...

cd /home/core
git clone https://github.com/clusterhq/gentoo

cd /home/core/gentoo
./coreos-zfs-builder ./startprefix ./build.sh
