# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/timezone-data/timezone-data-2011n.ebuild,v 1.2 2012/01/01 07:15:43 vapier Exp $

inherit eutils toolchain-funcs flag-o-matic

code_ver=${PV%n}i
data_ver=${PV}
DESCRIPTION="Timezone data (/usr/share/zoneinfo) and utilities (tzselect/zic/zdump)"
HOMEPAGE="http://www.twinsun.com/tz/tz-link.htm https://mm.icann.org/mailman/listinfo/tz"
SRC_URI="ftp://munnari.oz.au/pub/tzdata${data_ver}.tar.gz
	ftp://munnari.oz.au/pub/tzcode${code_ver}.tar.gz"

LICENSE="BSD public-domain"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="nls elibc_FreeBSD elibc_glibc"

RDEPEND="!<sys-libs/glibc-2.3.5"

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}"/${PN}-2008h-makefile.patch
	tc-is-cross-compiler && cp -pR "${S}" "${S}"-native
}

src_compile() {
	local LDLIBS
	tc-export CC
	use elibc_FreeBSD && append-flags -DSTD_INSPIRED #138251
	if use nls ; then
		use elibc_glibc || LDLIBS="${LDLIBS} -lintl" #154181
		export NLS=1
	else
		export NLS=0
	fi
	# Makefile uses LBLIBS for the libs (which defaults to LDFLAGS)
	# But it also uses LFLAGS where it expects the real LDFLAGS
	emake \
		LDLIBS="${LDLIBS}" \
		|| die "emake failed"
	if tc-is-cross-compiler ; then
		emake -C "${S}"-native \
			CC=$(tc-getBUILD_CC) \
			CFLAGS="${BUILD_CFLAGS}" \
			LDFLAGS="${BUILD_LDFLAGS}" \
			LDLIBS="${LDLIBS}" \
			zic || die
	fi
}

src_install() {
	local zic=""
	tc-is-cross-compiler && zic="zic=${S}-native/zic"
	emake install ${zic} DESTDIR="${D}" || die
	rm -rf "${D}"/usr/share/zoneinfo-leaps
	dodoc README Theory
	dohtml *.htm
}

pkg_config() {
	# make sure the /etc/localtime file does not get stale #127899
	local tz src etc_lt="${ROOT}etc/localtime"

	if has_version '<sys-apps/baselayout-2' ; then
		src="${ROOT}etc/conf.d/clock"
		tz=$(unset TIMEZONE ; source "${src}" ; echo ${TIMEZONE-FOOKABLOIE})
	else
		src="${ROOT}etc/timezone"
		if [[ -e ${src} ]] ; then
			tz=$(sed -e 's:#.*::' -e 's:[[:space:]]*::g' -e '/^$/d' "${src}")
		else
			tz="FOOKABLOIE"
		fi
	fi
	[[ -z ${tz} ]] && return 0

	if [[ ${tz} == "FOOKABLOIE" ]] ; then
		elog "You do not have TIMEZONE set in ${src}."

		if [[ ! -e ${etc_lt} ]] ; then
			# if /etc/localtime is a symlink somewhere, assume they
			# know what they're doing and they're managing it themselves
			if [[ ! -L ${etc_lt} ]] ; then
				cp -f "${ROOT}"/usr/share/zoneinfo/Factory "${etc_lt}"
				elog "Setting ${etc_lt} to Factory."
			else
				elog "Assuming your ${etc_lt} symlink is what you want; skipping update."
			fi
		else
			elog "Skipping auto-update of ${etc_lt}."
		fi
		return 0
	fi

	if [[ ! -e ${ROOT}/usr/share/zoneinfo/${tz} ]] ; then
		elog "You have an invalid TIMEZONE setting in ${src}"
		elog "Your ${etc_lt} has been reset to Factory; enjoy!"
		tz="Factory"
	fi
	einfo "Updating ${etc_lt} with ${ROOT}usr/share/zoneinfo/${tz}"
	[[ -L ${etc_lt} ]] && rm -f "${etc_lt}"
	cp -f "${ROOT}"/usr/share/zoneinfo/"${tz}" "${etc_lt}"
}

pkg_postinst() {
	pkg_config
}
