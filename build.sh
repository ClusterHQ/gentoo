#!/bin/bash -xe

EPREFIX=/home/core/gentoo

cd /home/core
if [[ ! -d kernel-coreos-$(uname -r | sed 's/+$//') ]]; then
    git clone https://github.com/coreos/linux.git kernel-coreos-$(uname -r | sed 's/+$//')
    cd kernel-coreos-$(uname -r | sed 's/+$//')
    git checkout tags/v$(uname -r | sed 's/+$//')
    cd ..
fi

zcat /proc/config.gz > kernel-coreos-$(uname -r | sed 's/+$//')/.config
sed -i -e '/CONFIG_SYSTEM_TRUSTED_KEYRING=y/d' kernel-coreos-$(uname -r | sed 's/+$//')/.config
touch kernel-coreos-$(uname -r | sed 's/+$//')/.x509.list
touch kernel-coreos-$(uname -r | sed 's/+$//')/bootengine.cpio
#make -j8 -C $HOME/kernel-coreos-$(uname -r | sed 's/+$//') vmlinux modules

if [ -f ${EPREFIX}/etc/portage/package.unmask ]
then
    mv ${EPREFIX}/etc/portage/package.unmask{,.bak}
    mkdir ${EPREFIX}/etc/portage/package.unmask
    mv ${EPREFIX}/etc/portage/package.unmask{.bak,/coreos}
fi

if [ -f ${EPREFIX}/etc/portage/package.accept_keywords ]
then
    mv ${EPREFIX}/etc/portage/package.accept_keywords{,.bak}
    mkdir ${EPREFIX}/etc/portage/package.accept_keywords
    mv ${EPREFIX}/etc/portage/package.accept_keywords{.bak,/coreos}
fi

# attempt to build latest git version of zfs and spl with "=[pkgname]-9999" syntax.
if [ ! -f ${EPREFIX}/etc/portage/package.unmask/core-zfs-9999 ]
then
    echo "=sys-kernel/spl-9999" >> ${EPREFIX}/etc/portage/package.unmask/core-zfs-9999
    echo "=sys-fs/zfs-kmod-9999" >> ${EPREFIX}/etc/portage/package.unmask/core-zfs-9999
    echo "=sys-fs/zfs-9999" >> ${EPREFIX}/etc/portage/package.unmask/core-zfs-9999
fi

if [ ! -f ${EPREFIX}/etc/portage/package.accept_keywords/core-zfs-9999 ]
then
    echo "sys-kernel/spl **" >> ${EPREFIX}/etc/portage/package.accept_keywords/core-zfs-9999
    echo "sys-fs/zfs-kmod **" >> ${EPREFIX}/etc/portage/package.accept_keywords/core-zfs-9999
    echo "sys-fs/zfs **" >> ${EPREFIX}/etc/portage/package.accept_keywords/core-zfs-9999
fi

env KERNEL_DIR=$HOME/kernel-coreos-$(uname -r | sed 's/+$//') EXTRA_ECONF="--disable-systemd --with-udevdir=$HOME/gentoo/lib/udev --with-dracutdir=$HOME/gentoo/usr/lib/dracut --with-linux=$HOME/kernel-coreos-$(uname -r | sed 's/+$//')" KV_OUT_DIR=$HOME/kernel-coreos-$(uname -r | sed 's/+$//') emerge -j8 -1v =sys-kernel/spl-9999 =sys-fs/zfs-kmod-9999 =sys-fs/zfs-9999
cp ~/kernel-coreos-$(uname -r | sed 's/+$//')/modules.{order,builtin} ${EPREFIX}/lib/modules/$(uname -r)/
depmod -b ~/gentoo
