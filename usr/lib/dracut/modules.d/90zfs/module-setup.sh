#!/bin/sh

check() {
	# We depend on udev-rules being loaded
	[ "$1" = "-d" ] && return 0

	# Verify the zfs tool chain
	which zpool >/dev/null 2>&1 || return 1
	which zfs >/dev/null 2>&1 || return 1

	return 0
}

depends() {
	echo udev-rules
	return 0
}

installkernel() {
	instmods zfs
	instmods zcommon
	instmods znvpair
	instmods zavl
	instmods zunicode
	instmods spl
	instmods zlib_deflate
	instmods zlib_inflate
}

install() {
	inst_rules /home/core/gentoo/lib/udev/rules.d/90-zfs.rules
	inst_rules /home/core/gentoo/lib/udev/rules.d/69-vdev.rules
	inst_rules /home/core/gentoo/lib/udev/rules.d/60-zvol.rules
	dracut_install /home/core/gentoo/sbin/zfs
	dracut_install /home/core/gentoo/sbin/zpool
	dracut_install /home/core/gentoo/lib/udev/vdev_id
	dracut_install /home/core/gentoo/lib/udev/zvol_id
	dracut_install mount.zfs
	dracut_install hostid
	inst_hook cmdline 95 "$moddir/parse-zfs.sh"
	inst_hook mount 98 "$moddir/mount-zfs.sh"

	if [ -e /home/core/gentoo/etc/zfs/zpool.cache ]; then
		inst /home/core/gentoo/etc/zfs/zpool.cache
	fi

	# Synchronize initramfs and system hostid
	TMP=`mktemp`
	AA=`hostid | cut -b 1,2`
	BB=`hostid | cut -b 3,4`
	CC=`hostid | cut -b 5,6`
	DD=`hostid | cut -b 7,8`
	printf "\x$DD\x$CC\x$BB\x$AA" >$TMP
	inst_simple "$TMP" /etc/hostid
	rm "$TMP"
}
