#!/usr/bin/bash

tar zcfv zfs-linux-$(uname -r).tar.gz \
	gentoo/usr/sbin/{zpool,zfs} \
	gentoo/usr/lib/modules/$(uname -r) \
	gentoo/lib \
	gentoo/sbin \
	gentoo/usr/lib/*.so* \
	gentoo/usr/lib/libnvpair* \
	gentoo/usr/lib/libuutil* \
	gentoo/usr/lib/libzpool* \
	gentoo/usr/lib/libzfs* \
	gentoo/usr/lib/libm* \
	gentoo/usr/lib/libdl* \
	gentoo/usr/lib/libblkid* \
	gentoo/usr/lib/librt* \
	gentoo/usr/lib/libuuid* \
	gentoo/usr/lib/libz* \
	gentoo/usr/lib/libpthread* \
	gentoo/usr/lib/libc* \
	gentoo/usr/lib/ld-linux-x86-64*
