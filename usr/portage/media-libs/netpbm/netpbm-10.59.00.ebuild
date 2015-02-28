# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/netpbm/netpbm-10.59.00.ebuild,v 1.1 2012/07/18 21:50:27 vapier Exp $

EAPI="4"

inherit toolchain-funcs eutils multilib prefix

DESCRIPTION="A set of utilities for converting to/from the netpbm (and related) formats"
HOMEPAGE="http://netpbm.sourceforge.net/"
SRC_URI="mirror://gentoo/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc jbig jpeg jpeg2k png rle svga tiff X xml zlib"

RDEPEND="jbig? ( media-libs/jbigkit )
	jpeg? ( virtual/jpeg )
	jpeg2k? ( media-libs/jasper )
	png? ( >=media-libs/libpng-1.4:0 )
	rle? ( media-libs/urt )
	svga? ( media-libs/svgalib )
	tiff? ( >=media-libs/tiff-3.5.5:0 )
	xml? ( dev-libs/libxml2 )
	zlib? ( sys-libs/zlib )
	X? ( x11-libs/libX11 )"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	sys-devel/flex"

netpbm_libtype() {
	case ${CHOST} in
		*-darwin*) echo dylib;;
		*)         echo unixshared;;
	esac
}
netpbm_libsuffix() {
	local suffix=$(get_libname)
	echo ${suffix//\.}
}
netpbm_ldshlib() {
	# ultra dirty Darwin hack, but hey... in the end this is all it needs...
	case ${CHOST} in
		*-darwin*) echo '$(LDFLAGS) -dynamiclib -install_name ${EPREFIX}/usr/lib/libnetpbm.$(MAJ).dylib';;
		*)         echo '$(LDFLAGS) -shared -Wl,-soname,$(SONAME)';;
	esac
}
netpbm_config() {
	if use $1 ; then
		[[ $2 != "!" ]] && echo -l${2:-$1}
	else
		echo NONE
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/netpbm-10.31-build.patch

	epatch "${FILESDIR}"/${PN}-10.46.00-solaris.patch
	epatch "${FILESDIR}"/${PN}-10.48.00-solaris.patch
	#epatch "${FILESDIR}"/${PN}-10.57.00-solaris-xopensource.patch
	#epatch "${FILESDIR}"/${PN}-10.48.00-interix.patch
	epatch "${FILESDIR}"/${PN}-10.60.01-strcaseeq-strcasecmp.patch
	epatch "${FILESDIR}"/netpbm-prefix.patch
	eprefixify converter/pbm/pbmtox10bm generator/ppmrainbow \
		editor/{ppmfade,pnmflip,pnmquant,ppmquant,ppmshadow}

	# make sure we use system urt
	sed -i '/SUPPORT_SUBDIRS/s:urt::' GNUmakefile || die
	rm -rf urt

	# take care of the importinc stuff ourselves by only doing it once
	# at the top level and having all subdirs use that one set #149843
	sed -i \
		-e '/^importinc:/s|^|importinc:\nmanual_|' \
		-e '/-Iimportinc/s|-Iimp|-I"$(BUILDDIR)"/imp|g'\
		common.mk || die
	sed -i \
		-e '/%.c/s: importinc$::' \
		common.mk lib/Makefile lib/util/Makefile || die

	# avoid ugly depend.mk warnings
	touch $(find . -name Makefile | sed s:Makefile:depend.mk:g)
}

src_configure() {
	cat config.mk.in - >> config.mk <<-EOF
	# Misc crap
	BUILD_FIASCO = N
	SYMLINK = ln -sf

	# Toolchain options
	CC = $(tc-getCC) -Wall
	LD = \$(CC)
	CC_FOR_BUILD = $(tc-getBUILD_CC)
	LD_FOR_BUILD = \$(CC_FOR_BUILD)
	AR = $(tc-getAR)
	RANLIB = $(tc-getRANLIB)

	STRIPFLAG =
	CFLAGS_SHLIB = -fPIC

	LDRELOC = \$(LD) -r
	LDSHLIB = $(netpbm_ldshlib)
	LINKER_CAN_DO_EXPLICIT_LIBRARY = N # we can, but dont want to
	LINKERISCOMPILER = Y
	NETPBMLIBSUFFIX = $(netpbm_libsuffix)
	NETPBMLIBTYPE = $(netpbm_libtype)

	# Gentoo build options
	TIFFLIB = $(netpbm_config tiff)
	# Let tiff worry about its own dependencies #395753
	TIFFLIB_NEEDS_JPEG = N
	TIFFLIB_NEEDS_Z = N
	JPEGLIB = $(netpbm_config jpeg)
	PNGLIB = $(netpbm_config png)
	ZLIB = $(netpbm_config zlib z)
	LINUXSVGALIB = $(netpbm_config svga vga)
	XML2_LIBS = $(netpbm_config xml xml2)
	JBIGLIB = -ljbig
	JBIGHDR_DIR = $(netpbm_config jbig "!")
	JASPERLIB = -ljasper
	JASPERHDR_DIR = $(netpbm_config jpeg2k "!")
	URTLIB = $(netpbm_config rle)
	URTHDR_DIR =
	X11LIB = $(netpbm_config X X11)
	X11HDR_DIR =
	EOF
	# cannot chain the die with the heredoc above as bash-3
	# has a parser bug in that setup #282902
	[ $? -eq 0 ] || die "writing config.mk failed"
}

src_compile() {
	# Solaris doesn't have vasprintf, libiberty does have it, for gethostbyname
	# we need -lnsl, for connect -lsocket
	[[ ${CHOST} == *-solaris* ]] && extlibs="-liberty -lnsl -lsocket"
	# same holds for interix, but we only need iberty
	[[ ${CHOST} == *-interix* ]] && extlibs="-liberty"

	emake LIBS="${extlibs}" -j1 pm_config.h version.h manual_importinc #149843
	emake LIBS="${extlibs}"
}

src_install() {
	mkdir -p "${ED}"
	# Subdir make targets like to use `mkdir` all over the place
	# without any actual dependencies, thus the -j1.
	emake -j1 package pkgdir="${ED}"/usr

	[[ $(get_libdir) != "lib" ]] && mv "${ED}"/usr/lib "${ED}"/usr/$(get_libdir)

	# Remove cruft that we don't need, and move around stuff we want
	rm "${ED}"/usr/bin/{doc.url,manweb} || die
	rm -r "${ED}"/usr/man/web || die
	rm -r "${ED}"/usr/link || die
	rm "${ED}"/usr/{README,VERSION,config_template,pkginfo} || die
	dodir /usr/share
	mv "${ED}"/usr/man "${ED}"/usr/share/ || die
	mv "${ED}"/usr/misc "${ED}"/usr/share/netpbm || die

	doman userguide/*.[0-9]
	use doc && dohtml -r userguide
	dodoc README
	cd doc
	dodoc HISTORY Netpbm.programming USERDOC
	dohtml -r .
}
