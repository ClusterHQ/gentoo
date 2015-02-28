/* zfs_config.h.  Generated from zfs_config.h.in by configure.  */
/* zfs_config.h.in.  Generated from configure.ac by autoheader.  */

/* Define to 1 to enabled dmu tx validation */
/* #undef DEBUG_DMU_TX */

/* invalidate_bdev() wants 1 arg */
#define HAVE_1ARG_INVALIDATE_BDEV 1

/* bio_end_io_t wants 2 args */
#define HAVE_2ARGS_BIO_END_IO_T 1

/* blkdev_get() wants 3 args */
#define HAVE_3ARG_BLKDEV_GET 1

/* sget() wants 5 args */
#define HAVE_5ARG_SGET 1

/* security_inode_init_security wants 6 args */
/* #undef HAVE_6ARGS_SECURITY_INODE_INIT_SECURITY */

/* dops->automount() exists */
#define HAVE_AUTOMOUNT 1

/* struct block_device_operations use bdevs */
#define HAVE_BDEV_BLOCK_DEVICE_OPERATIONS 1

/* bdev_logical_block_size() is available */
#define HAVE_BDEV_LOGICAL_BLOCK_SIZE 1

/* bdev_physical_block_size() is available */
#define HAVE_BDEV_PHYSICAL_BLOCK_SIZE 1

/* struct super_block has s_bdi */
#define HAVE_BDI 1

/* bdi_setup_and_register() is available */
#define HAVE_BDI_SETUP_AND_REGISTER 1

/* bio has bi_iter */
#define HAVE_BIO_BVEC_ITER 1

/* REQ_FAILFAST_MASK is defined */
#define HAVE_BIO_REQ_FAILFAST_MASK 1

/* BIO_RW_FAILFAST is defined */
/* #undef HAVE_BIO_RW_FAILFAST */

/* BIO_RW_FAILFAST_* are defined */
/* #undef HAVE_BIO_RW_FAILFAST_DTD */

/* BIO_RW_SYNC is defined */
/* #undef HAVE_BIO_RW_SYNC */

/* BIO_RW_SYNCIO is defined */
/* #undef HAVE_BIO_RW_SYNCIO */

/* blkdev_get_by_path() is available */
#define HAVE_BLKDEV_GET_BY_PATH 1

/* blk_end_request() is available */
#define HAVE_BLK_END_REQUEST 1

/* blk_end_request() is GPL-only */
/* #undef HAVE_BLK_END_REQUEST_GPL_ONLY */

/* blk_fetch_request() is available */
#define HAVE_BLK_FETCH_REQUEST 1

/* blk_queue_discard() is available */
#define HAVE_BLK_QUEUE_DISCARD 1

/* blk_queue_flush() is available */
#define HAVE_BLK_QUEUE_FLUSH 1

/* blk_queue_flush() is GPL-only */
#define HAVE_BLK_QUEUE_FLUSH_GPL_ONLY 1

/* blk_queue_io_opt() is available */
#define HAVE_BLK_QUEUE_IO_OPT 1

/* blk_queue_max_hw_sectors() is available */
#define HAVE_BLK_QUEUE_MAX_HW_SECTORS 1

/* blk_queue_max_segments() is available */
#define HAVE_BLK_QUEUE_MAX_SEGMENTS 1

/* blk_queue_nonrot() is available */
#define HAVE_BLK_QUEUE_NONROT 1

/* blk_queue_physical_block_size() is available */
#define HAVE_BLK_QUEUE_PHYSICAL_BLOCK_SIZE 1

/* blk_requeue_request() is available */
#define HAVE_BLK_REQUEUE_REQUEST 1

/* blk_rq_bytes() is available */
#define HAVE_BLK_RQ_BYTES 1

/* blk_rq_bytes() is GPL-only */
/* #undef HAVE_BLK_RQ_BYTES_GPL_ONLY */

/* blk_rq_pos() is available */
#define HAVE_BLK_RQ_POS 1

/* blk_rq_sectors() is available */
#define HAVE_BLK_RQ_SECTORS 1

/* struct block_device_operations.release returns void */
#define HAVE_BLOCK_DEVICE_OPERATIONS_RELEASE_VOID 1

/* security_inode_init_security wants callback */
#define HAVE_CALLBACK_SECURITY_INODE_INIT_SECURITY 1

/* iops->check_acl() exists */
/* #undef HAVE_CHECK_ACL */

/* iops->check_acl() wants flags */
/* #undef HAVE_CHECK_ACL_WITH_FLAGS */

/* check_disk_size_change() is available */
#define HAVE_CHECK_DISK_SIZE_CHANGE 1

/* clear_inode() is available */
#define HAVE_CLEAR_INODE 1

/* eops->commit_metadata() exists */
#define HAVE_COMMIT_METADATA 1

/* dentry uses const struct dentry_operations */
#define HAVE_CONST_DENTRY_OPERATIONS 1

/* super_block uses const struct xattr_hander */
#define HAVE_CONST_XATTR_HANDLER 1

/* iops->create() operation takes nameidata */
/* #undef HAVE_CREATE_NAMEIDATA */

/* current_umask() exists */
#define HAVE_CURRENT_UMASK 1

/* xattr_handler->get() wants dentry */
#define HAVE_DENTRY_XATTR_GET 1

/* xattr_handler->list() wants dentry */
#define HAVE_DENTRY_XATTR_LIST 1

/* xattr_handler->set() wants dentry */
#define HAVE_DENTRY_XATTR_SET 1

/* sops->dirty_inode() wants flags */
#define HAVE_DIRTY_INODE_WITH_FLAGS 1

/* ql->discard_granularity is available */
#define HAVE_DISCARD_GRANULARITY 1

/* Define to 1 if you have the <dlfcn.h> header file. */
#define HAVE_DLFCN_H 1

/* d_make_root() is available */
#define HAVE_D_MAKE_ROOT 1

/* d_obtain_alias() is available */
#define HAVE_D_OBTAIN_ALIAS 1

/* dops->d_revalidate() operation takes nameidata */
/* #undef HAVE_D_REVALIDATE_NAMEIDATA */

/* d_set_d_op() is available */
#define HAVE_D_SET_D_OP 1

/* elevator_change() is available */
#define HAVE_ELEVATOR_CHANGE 1

/* eops->encode_fh() wants child and parent inodes */
#define HAVE_ENCODE_FH_WITH_INODE 1

/* sops->evict_inode() exists */
#define HAVE_EVICT_INODE 1

/* fops->fallocate() exists */
#define HAVE_FILE_FALLOCATE 1

/* kernel defines fmode_t */
#define HAVE_FMODE_T 1

/* sops->free_cached_objects() exists */
/* #undef HAVE_FREE_CACHED_OBJECTS */

/* fops->fsync() with range */
#define HAVE_FSYNC_RANGE 1

/* fops->fsync() without dentry */
/* #undef HAVE_FSYNC_WITHOUT_DENTRY */

/* fops->fsync() with dentry */
/* #undef HAVE_FSYNC_WITH_DENTRY */

/* iops->get_acl() exists */
#define HAVE_GET_ACL 1

/* blk_disk_ro() is available */
#define HAVE_GET_DISK_RO 1

/* get_gendisk() is available */
#define HAVE_GET_GENDISK 1

/* Define to 1 if licensed under the GPL */
/* #undef HAVE_GPL_ONLY_SYMBOLS */

/* fops->fallocate() exists */
/* #undef HAVE_INODE_FALLOCATE */

/* inode_owner_or_capable() exists */
#define HAVE_INODE_OWNER_OR_CAPABLE 1

/* iops->truncate_range() exists */
/* #undef HAVE_INODE_TRUNCATE_RANGE */

/* insert_inode_locked() is available */
#define HAVE_INSERT_INODE_LOCKED 1

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* result=stropts.h Define to 1 if ioctl() defined in <stropts.h> */
/* #undef HAVE_IOCTL_IN_STROPTS_H */

/* Define to 1 if ioctl() defined in <sys/ioctl.h> */
/* #undef HAVE_IOCTL_IN_SYS_IOCTL_H */

/* Define to 1 if ioctl() defined in <unistd.h> */
/* #undef HAVE_IOCTL_IN_UNISTD_H */

/* is_owner_or_cap() exists */
/* #undef HAVE_IS_OWNER_OR_CAP */

/* kernel defines KOBJ_NAME_LEN */
/* #undef HAVE_KOBJ_NAME_LEN */

/* Define if you have libblkid */
/* #undef HAVE_LIBBLKID */

/* Define if you have libuuid */
/* #undef HAVE_LIBUUID */

/* Define to 1 if you have the `z' library (-lz). */
/* #undef HAVE_LIBZ */

/* lookup_bdev() is available */
#define HAVE_LOOKUP_BDEV 1

/* iops->lookup() operation takes nameidata */
/* #undef HAVE_LOOKUP_NAMEIDATA */

/* lseek_execute() is available */
/* #undef HAVE_LSEEK_EXECUTE */

/* Define to 1 if you have the <memory.h> header file. */
#define HAVE_MEMORY_H 1

/* iops->create()/mkdir()/mknod() take umode_t */
#define HAVE_MKDIR_UMODE_T 1

/* Define to 1 if you have the `mlockall' function. */
/* #undef HAVE_MLOCKALL */

/* mount_nodev() is available */
#define HAVE_MOUNT_NODEV 1

/* sops->nr_cached_objects() exists */
/* #undef HAVE_NR_CACHED_OBJECTS */

/* open_bdev_exclusive() is available */
/* #undef HAVE_OPEN_BDEV_EXCLUSIVE */

/* iops->permission() exists */
#define HAVE_PERMISSION 1

/* iops->permission() with nameidata exists */
/* #undef HAVE_PERMISSION_WITH_NAMEIDATA */

/* inode contains i_acl and i_default_acl */
#define HAVE_POSIX_ACL_CACHING 1

/* posix_acl_chmod() exists */
/* #undef HAVE_POSIX_ACL_CHMOD */

/* posix_acl_equiv_mode wants umode_t* */
#define HAVE_POSIX_ACL_EQUIV_MODE_UMODE_T 1

/* posix_acl_from_xattr() needs user_ns */
#define HAVE_POSIX_ACL_FROM_XATTR_USERNS 1

/* posix_acl_release() is available */
#define HAVE_POSIX_ACL_RELEASE 1

/* posix_acl_release() is GPL-only */
#define HAVE_POSIX_ACL_RELEASE_GPL_ONLY 1

/* REQ_SYNC is defined */
#define HAVE_REQ_SYNC 1

/* rq_for_each_segment() is available */
#define HAVE_RQ_FOR_EACH_SEGMENT 1

/* rq_for_each_segment() wants bio_vec */
#define HAVE_RQ_FOR_EACH_SEGMENT_BV 1

/* rq_for_each_segment() wants bio_vec * */
/* #undef HAVE_RQ_FOR_EACH_SEGMENT_BVP */

/* rq_is_sync() is available */
#define HAVE_RQ_IS_SYNC 1

/* set_nlink() is available */
#define HAVE_SET_NLINK 1

/* sops->show_options() with dentry */
#define HAVE_SHOW_OPTIONS_WITH_DENTRY 1

/* struct super_block has s_shrink */
/* #undef HAVE_SHRINK */

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* struct super_block has s_d_op */
#define HAVE_S_D_OP 1

/* struct super_block has s_instances list_head */
/* #undef HAVE_S_INSTANCES_LIST_HEAD */

/* truncate_setsize() is available */
#define HAVE_TRUNCATE_SETSIZE 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* fops->iterate() is available */
#define HAVE_VFS_ITERATE 1

/* fops->readdir() is available */
/* #undef HAVE_VFS_READDIR */

/* Define if you have zlib */
/* #undef HAVE_ZLIB */

/* __posix_acl_chmod() exists */
#define HAVE___POSIX_ACL_CHMOD 1

/* Define to the sub-directory in which libtool stores uninstalled libraries.
   */
#define LT_OBJDIR ".libs/"

/* zfs debugging enabled */
/* #undef ZFS_DEBUG */

/* Define the project alias string. */
#define ZFS_META_ALIAS "zfs-0.6.3-r0-gentoo"

/* Define the project author. */
#define ZFS_META_AUTHOR "Sun Microsystems/Oracle, Lawrence Livermore National Laboratory"

/* Define the project release date. */
/* #undef ZFS_META_DATA */

/* Define the project license. */
#define ZFS_META_LICENSE "CDDL"

/* Define the libtool library 'age' version information. */
/* #undef ZFS_META_LT_AGE */

/* Define the libtool library 'current' version information. */
/* #undef ZFS_META_LT_CURRENT */

/* Define the libtool library 'revision' version information. */
/* #undef ZFS_META_LT_REVISION */

/* Define the project name. */
#define ZFS_META_NAME "zfs"

/* Define the project release. */
#define ZFS_META_RELEASE "r0-gentoo"

/* Define the project version. */
#define ZFS_META_VERSION "0.6.3"

