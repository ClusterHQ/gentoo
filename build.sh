#!/bin/bash -xe
cd /home/core
git checkout https://github.com/coreos/linux.git kernel-coreos-$(uname -r | sed 's/+$//')
cd kernel-coreos-$(uname -r | sed 's/+$//')
git checkout tags/v$(uname -r | sed 's/+$//')
cd ..
zcat /proc/config.gz > kernel-coreos-$(uname -r | sed 's/+$//')/.config
sed -i -e '/CONFIG_SYSTEM_TRUSTED_KEYRING=y/d' kernel-coreos-$(uname -r | sed 's/+$//')/.config
touch kernel-coreos-$(uname -r | sed 's/+$//')/.x509.list
touch kernel-coreos-$(uname -r | sed 's/+$//')/bootengine.cpio
make -C $HOME/kernel-coreos-$(uname -r | sed 's/+$//') vmlinux modules
env EXTRA_ECONF="--with-linux=$HOME/kernel-coreos-$(uname -r | sed 's/+$//')" KV_OUT_DIR=$HOME/kernel-coreos-$(uname -r | sed 's/+$//') emerge -1v sys-kernel/spl sys-fs/zfs-kmod
cp ~/kernel-coreos-$(uname -r | sed 's/+$//')/modules.{order,builtin} /home/core/gentoo/lib/modules/$(uname -r)/
depmod -b ~/gentoo
