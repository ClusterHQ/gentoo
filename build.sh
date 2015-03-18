#!/bin/bash -xe

EPREFIX=/home/core/gentoo

cd /home/core
if [[ ! -d linux-$(uname -r | sed 's/+$//') ]]; then
    wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-$(uname -r | sed 's/+$//').tar.xz
    tar xf linux-$(uname -r | sed 's/+$//').tar.xz
    cd linux-$(uname -r | sed 's/+$//')
    cd ..
fi

zcat /proc/config.gz > linux-$(uname -r | sed 's/+$//')/.config
sed -i -e '/CONFIG_SYSTEM_TRUSTED_KEYRING=y/d' linux-$(uname -r | sed 's/+$//')/.config
touch linux-$(uname -r | sed 's/+$//')/.x509.list
touch linux-$(uname -r | sed 's/+$//')/bootengine.cpio
make -j8 -C $HOME/linux-$(uname -r | sed 's/+$//') vmlinux modules

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
    mkdir -p ${EPREFIX}/etc/portage/package.unmask
    echo "=sys-kernel/spl-9999" >> ${EPREFIX}/etc/portage/package.unmask/core-zfs-9999
    echo "=sys-fs/zfs-kmod-9999" >> ${EPREFIX}/etc/portage/package.unmask/core-zfs-9999
    echo "=sys-fs/zfs-9999" >> ${EPREFIX}/etc/portage/package.unmask/core-zfs-9999
fi

if [ ! -f ${EPREFIX}/etc/portage/package.accept_keywords/core-zfs-9999 ]
then
    mkdir -p ${EPREFIX}/etc/portage/package.accept_keywords
    echo "sys-kernel/spl **" >> ${EPREFIX}/etc/portage/package.accept_keywords/core-zfs-9999
    echo "sys-fs/zfs-kmod **" >> ${EPREFIX}/etc/portage/package.accept_keywords/core-zfs-9999
    echo "sys-fs/zfs **" >> ${EPREFIX}/etc/portage/package.accept_keywords/core-zfs-9999
fi

env KERNEL_DIR=$HOME/linux-$(uname -r | sed 's/+$//') EXTRA_ECONF="--disable-systemd --with-udevdir=$HOME/gentoo/lib/udev --with-dracutdir=$HOME/gentoo/usr/lib/dracut --with-linux=$HOME/linux-$(uname -r | sed 's/+$//')" KV_OUT_DIR=$HOME/linux-$(uname -r | sed 's/+$//') emerge -j8 -1v =sys-kernel/spl-9999 =sys-fs/zfs-kmod-9999 =sys-fs/zfs-9999
cp ~/linux-$(uname -r | sed 's/+$//')/modules.{order,builtin} ${EPREFIX}/lib/modules/$(uname -r)/
depmod -b ~/gentoo
