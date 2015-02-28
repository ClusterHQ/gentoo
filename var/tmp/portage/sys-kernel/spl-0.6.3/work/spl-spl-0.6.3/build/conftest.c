/* confdefs.h */
#define PACKAGE_NAME ""
#define PACKAGE_TARNAME ""
#define PACKAGE_VERSION ""
#define PACKAGE_STRING ""
#define PACKAGE_BUGREPORT ""
#define PACKAGE_URL ""
#define SPL_META_NAME "spl"
#define SPL_META_VERSION "0.6.3"
#define SPL_META_RELEASE "r0-gentoo"
#define SPL_META_ALIAS "spl-0.6.3-r0-gentoo"
#define PACKAGE "spl"
#define VERSION "0.6.3"
#define STDC_HEADERS 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRING_H 1
#define HAVE_MEMORY_H 1
#define HAVE_STRINGS_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_STDINT_H 1
#define HAVE_UNISTD_H 1
#define HAVE_DLFCN_H 1
#define LT_OBJDIR ".libs/"
#define DEBUG_KMEM 1
#define HAVE_ATOMIC64_T 1
#define HAVE_ATOMIC64_CMPXCHG 1
#define HAVE_ATOMIC64_XCHG 1
#define HAVE_UINTPTR_T 1


				#include <linux/mm.h>

				int shrinker_cb(struct shrinker *,
						struct shrink_control *sc);

int
main (void)
{

				struct shrinker cache_shrinker = {
					.shrink = shrinker_cb,
					.seeks = DEFAULT_SEEKS,
				};
				register_shrinker(&cache_shrinker);

  ;
  return 0;
}

