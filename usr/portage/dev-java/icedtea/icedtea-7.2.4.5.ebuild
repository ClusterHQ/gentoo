# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/icedtea/icedtea-7.2.4.5.ebuild,v 1.3 2014/05/17 15:22:54 swift Exp $
# Build written by Andrew John Hughes (gnu_andrew@member.fsf.org)

# *********************************************************
# * IF YOU CHANGE THIS EBUILD, CHANGE ICEDTEA-6.* AS WELL *
# *********************************************************

EAPI="5"

inherit java-pkg-2 java-vm-2 pax-utils prefix versionator virtualx

ICEDTEA_VER=$(get_version_component_range 2-)
ICEDTEA_BRANCH=$(get_version_component_range 2-3)
ICEDTEA_PKG=icedtea-${ICEDTEA_VER}
CORBA_TARBALL="3594dbde270d.tar.gz"
JAXP_TARBALL="8fe156ad49e2.tar.gz"
JAXWS_TARBALL="32ea8b1ed91a.tar.gz"
JDK_TARBALL="9db88c18e114.tar.gz"
LANGTOOLS_TARBALL="dabd37b7e295.tar.gz"
OPENJDK_TARBALL="410eb7fef869.tar.gz"
HOTSPOT_TARBALL="2cb58882dac3.tar.gz"
CACAO_TARBALL="e215e36be9fc.tar.gz"
JAMVM_TARBALL="jamvm-ac22c9948434e528ece451642b4ebde40953ee7e.tar.gz"

CORBA_GENTOO_TARBALL="icedtea-${ICEDTEA_BRANCH}-corba-${CORBA_TARBALL}"
JAXP_GENTOO_TARBALL="icedtea-${ICEDTEA_BRANCH}-jaxp-${JAXP_TARBALL}"
JAXWS_GENTOO_TARBALL="icedtea-${ICEDTEA_BRANCH}-jaxws-${JAXWS_TARBALL}"
JDK_GENTOO_TARBALL="icedtea-${ICEDTEA_BRANCH}-jdk-${JDK_TARBALL}"
LANGTOOLS_GENTOO_TARBALL="icedtea-${ICEDTEA_BRANCH}-langtools-${LANGTOOLS_TARBALL}"
OPENJDK_GENTOO_TARBALL="icedtea-${ICEDTEA_BRANCH}-openjdk-${OPENJDK_TARBALL}"
HOTSPOT_GENTOO_TARBALL="icedtea-${ICEDTEA_BRANCH}-hotspot-${HOTSPOT_TARBALL}"
CACAO_GENTOO_TARBALL="icedtea-${ICEDTEA_BRANCH}-cacao-${CACAO_TARBALL}"
JAMVM_GENTOO_TARBALL="icedtea-${ICEDTEA_BRANCH}-${JAMVM_TARBALL}"

DESCRIPTION="A harness to build OpenJDK using Free Software build tools and dependencies"
HOMEPAGE="http://icedtea.classpath.org"
SRC_PKG="${ICEDTEA_PKG}.tar.xz"
SRC_URI="
	http://icedtea.classpath.org/download/source/${SRC_PKG}
	http://icedtea.classpath.org/hg/release/icedtea7-forest-${ICEDTEA_BRANCH}/archive/${OPENJDK_TARBALL}
	 -> ${OPENJDK_GENTOO_TARBALL}
	http://icedtea.classpath.org/hg/release/icedtea7-forest-${ICEDTEA_BRANCH}/corba/archive/${CORBA_TARBALL}
	 -> ${CORBA_GENTOO_TARBALL}
	http://icedtea.classpath.org/hg/release/icedtea7-forest-${ICEDTEA_BRANCH}/jaxp/archive/${JAXP_TARBALL}
	 -> ${JAXP_GENTOO_TARBALL}
	http://icedtea.classpath.org/hg/release/icedtea7-forest-${ICEDTEA_BRANCH}/jaxws/archive/${JAXWS_TARBALL}
	 -> ${JAXWS_GENTOO_TARBALL}
	http://icedtea.classpath.org/hg/release/icedtea7-forest-${ICEDTEA_BRANCH}/jdk/archive/${JDK_TARBALL}
	 -> ${JDK_GENTOO_TARBALL}
	http://icedtea.classpath.org/hg/release/icedtea7-forest-${ICEDTEA_BRANCH}/hotspot/archive/${HOTSPOT_TARBALL}
	 -> ${HOTSPOT_GENTOO_TARBALL}
	http://icedtea.classpath.org/hg/release/icedtea7-forest-${ICEDTEA_BRANCH}/langtools/archive/${LANGTOOLS_TARBALL}
	 -> ${LANGTOOLS_GENTOO_TARBALL}
	http://icedtea.classpath.org/download/drops/cacao/${CACAO_TARBALL} -> ${CACAO_GENTOO_TARBALL}
	http://icedtea.classpath.org/download/drops/jamvm/${JAMVM_TARBALL} -> ${JAMVM_GENTOO_TARBALL}"

LICENSE="Apache-1.1 Apache-2.0 GPL-1 GPL-2 GPL-2-with-linking-exception LGPL-2 MPL-1.0 MPL-1.1 public-domain W3C"
SLOT="7"
KEYWORDS="~amd64 ~ia64 ~x86"

IUSE="+X +alsa cacao cjk +cups debug doc examples javascript +jbootstrap kerberos +nsplugin
	+nss pax_kernel pulseaudio selinux +source test +webstart"

# Ideally the following were optional at build time.
ALSA_COMMON_DEP="
	>=media-libs/alsa-lib-1.0"
CUPS_COMMON_DEP="
	>=net-print/cups-1.2.12"
X_COMMON_DEP="
	>=dev-libs/atk-1.30.0
	>=dev-libs/glib-2.26
	media-libs/fontconfig
	>=media-libs/freetype-2.3.5:2=
	>=x11-libs/cairo-1.8.8:=
	x11-libs/gdk-pixbuf:2
	>=x11-libs/gtk+-2.8:2=
	>=x11-libs/libX11-1.1.3
	>=x11-libs/libXext-1.1.1
	>=x11-libs/libXi-1.1.3
	>=x11-libs/libXrender-0.9.4
	>=x11-libs/libXtst-1.0.3
	>=x11-libs/pango-1.24.5"
X_DEPEND="
	>=x11-libs/libXau-1.0.3
	>=x11-libs/libXdmcp-1.0.2
	>=x11-libs/libXinerama-1.0.2
	x11-proto/inputproto
	>=x11-proto/xextproto-7.1.1
	x11-proto/xineramaproto
	x11-proto/xproto"

COMMON_DEP="
	>=media-libs/giflib-4.1.6:=
	>=media-libs/lcms-2.5
	>=media-libs/libpng-1.2:=
	>=sys-libs/zlib-1.2.3:=
	virtual/jpeg:0=
	javascript? ( dev-java/rhino:1.6 )
	nss? ( >=dev-libs/nss-3.12.5-r1 )
	pulseaudio?  ( >=media-sound/pulseaudio-0.9.11:= )
	selinux? ( sec-policy/selinux-java )
	kerberos? ( virtual/krb5 )
	>=dev-util/systemtap-1"

# cups is needed for X. #390945 #390975
RDEPEND="${COMMON_DEP}
	!dev-java/icedtea:0
	X? (
		${CUPS_COMMON_DEP}
		${X_COMMON_DEP}
		media-fonts/dejavu
		cjk? (
			media-fonts/arphicfonts
			media-fonts/baekmuk-fonts
			media-fonts/lklug
			media-fonts/lohit-fonts
			media-fonts/sazanami
		)
	)
	alsa? ( ${ALSA_COMMON_DEP} )
	cups? ( ${CUPS_COMMON_DEP} )"

# Only ant-core-1.8.1 has fixed ant -diagnostics when xerces+xalan are not present.
# ca-certificates, perl and openssl are used for the cacerts keystore generation
# xext headers have two variants depending on version - bug #288855
# autoconf - as long as we use eautoreconf, version restrictions for bug #294918
DEPEND="${COMMON_DEP} ${ALSA_COMMON_DEP} ${CUPS_COMMON_DEP} ${X_COMMON_DEP}
	|| (
		>=dev-java/gcj-jdk-4.3
		dev-java/icedtea-bin:7
		dev-java/icedtea-bin:6
		dev-java/icedtea:7
		dev-java/icedtea:6
	)
	app-arch/cpio
	app-arch/unzip
	app-arch/zip
	app-misc/ca-certificates
	>=dev-java/ant-core-1.9.2
	dev-lang/perl
	>=dev-libs/libxslt-1.1.26
	dev-libs/openssl
	virtual/pkgconfig
	sys-apps/attr
	sys-apps/lsb-release
	${X_DEPEND}
	pax_kernel? ( sys-apps/paxctl )"

PDEPEND="webstart? ( dev-java/icedtea-web:7 )
	nsplugin? ( dev-java/icedtea-web:7[nsplugin] )"

S="${WORKDIR}"/${ICEDTEA_PKG}

pkg_setup() {
	JAVA_PKG_WANT_BUILD_VM="
		icedtea-7 icedtea-bin-7 icedtea7
		icedtea-6 icedtea-bin-6 icedtea6 icedtea6-bin
		gcj-jdk"
	JAVA_PKG_WANT_SOURCE="1.5"
	JAVA_PKG_WANT_TARGET="1.5"

	java-vm-2_pkg_setup
	java-pkg-2_pkg_setup
}

src_unpack() {
	unpack ${SRC_PKG}
}

java_prepare() {
	# For bootstrap builds as the sandbox control file might not yet exist.
	addpredict /proc/self/coredump_filter

	# icedtea doesn't like some locales. #330433 #389717
	export LANG="C" LC_ALL="C"
}

src_configure() {
	local config bootstrap use_zero zero_config
	local vm=$(java-pkg_get-current-vm)

	# Whether to bootstrap
	bootstrap="disable"
	if use jbootstrap; then
		bootstrap="enable"
	fi

	if has "${vm}" gcj-jdk; then
		# gcj-jdk ensures ecj is present.
		use jbootstrap || einfo "bootstrap is necessary when building with ${vm}, ignoring USE=\"-jbootstrap\""
		bootstrap="enable"
		local ecj_jar="$(readlink "${EPREFIX}"/usr/share/eclipse-ecj/ecj.jar)"
		config="${config} --with-ecj-jar=${ecj_jar}"
	fi

	config="${config} --${bootstrap}-bootstrap"

	# Use CACAO if requested
	if use cacao; then
		use_cacao="yes";
	fi

	# Always use HotSpot as the primary VM if available. #389521 #368669 #357633 ...
	# Otherwise use CACAO
	if ! has "${ARCH}" amd64 sparc x86 ; then
		if has "${ARCH}" ppc ppc64 arm ; then
			use_cacao="yes";
		else
			use_zero="yes";
		fi
	fi

	# Turn on CACAO if needed (non-HS archs) or requested
	if test "x${use_cacao}" = "xyes"; then
		cacao_config="--enable-cacao";
	fi

	# Turn on Zero if needed (non-HS/CACAO archs) or requested
	if test "x${use_zero}" = "xyes"; then
		zero_config="--enable-zero";
	fi

	# OpenJDK-specific parallelism support. Bug #389791, #337827
	# Implementation modified from waf-utils.eclass
	# Note that "-j" is converted to "-j1" as the system doesn't support --load-average
	local procs=$(echo -j1 ${MAKEOPTS} | sed -r "s/.*(-j\s*|--jobs=)([0-9]+).*/\2/" )
	config="${config} --with-parallel-jobs=${procs}";
	einfo "Configuring using --with-parallel-jobs=${procs}"

	if use javascript ; then
		config="${config} --with-rhino=$(java-pkg_getjar rhino-1.6 js.jar)"
	else
		config="${config} --without-rhino"
	fi

	unset JAVA_HOME JDK_HOME CLASSPATH JAVAC JAVACFLAGS

	econf ${config} \
		--with-openjdk-src-zip="${DISTDIR}/${OPENJDK_GENTOO_TARBALL}" \
		--with-corba-src-zip="${DISTDIR}/${CORBA_GENTOO_TARBALL}" \
		--with-jaxp-src-zip="${DISTDIR}/${JAXP_GENTOO_TARBALL}" \
		--with-jaxws-src-zip="${DISTDIR}/${JAXWS_GENTOO_TARBALL}" \
		--with-jdk-src-zip="${DISTDIR}/${JDK_GENTOO_TARBALL}" \
		--with-hotspot-src-zip="${DISTDIR}/${HOTSPOT_GENTOO_TARBALL}" \
		--with-langtools-src-zip="${DISTDIR}/${LANGTOOLS_GENTOO_TARBALL}" \
		--with-cacao-src-zip="${DISTDIR}/${CACAO_GENTOO_TARBALL}" \
		--with-jamvm-src-zip="${DISTDIR}/${JAMVM_GENTOO_TARBALL}" \
		--with-jdk-home="$(java-config -O)" \
		--with-abs-install-dir=/usr/$(get_libdir)/icedtea${SLOT} \
		--disable-downloading --disable-Werror \
		--enable-system-lcms \
		$(use_enable !debug optimizations) \
		$(use_enable doc docs) \
		$(use_enable nss) \
		$(use_enable pulseaudio pulse-java) \
		$(use_enable kerberos system-kerberos) \
		$(use_with pax_kernel pax paxctl) \
		${zero_config} ${cacao_config}
}

src_compile() {
	# Would use GENTOO_VM otherwise.
	export ANT_RESPECT_JAVA_HOME=TRUE

	# With ant >=1.8.2 all required tasks are part of ant-core
	export ANT_TASKS="none"

	emake
}

src_test() {
	# Use Xvfb for tests
	unset DISPLAY

	Xemake check
}

src_install() {
	local dest="/usr/$(get_libdir)/icedtea${SLOT}"
	local ddest="${ED}/${dest}"
	dodir "${dest}"

	dodoc README NEWS AUTHORS
	dosym /usr/share/doc/${PF} /usr/share/doc/${PN}${SLOT}

	cd openjdk.build/j2sdk-image || die

	# Ensures HeadlessGraphicsEnvironment is used.
	if ! use X; then
		rm -r jre/lib/$(get_system_arch)/xawt || die
	fi

	# Don't hide classes
	rm lib/ct.sym || die

	#402507
	mkdir jre/.systemPrefs || die
	touch jre/.systemPrefs/.system.lock || die
	touch jre/.systemPrefs/.systemRootModFile || die

	# doins can't handle symlinks.
	cp -vRP bin include jre lib man "${ddest}" || die

	dodoc ASSEMBLY_EXCEPTION THIRD_PARTY_README

	if use doc; then
		# java-pkg_dohtml needed for package-list #302654
		java-pkg_dohtml -r ../docs/* || die
	fi

	if use examples; then
		dodir "${dest}/share";
		cp -vRP demo sample "${ddest}/share/" || die
	fi

	if use source; then
		cp src.zip "${ddest}" || die
	fi

	# Fix the permissions.
	find "${ddest}" \! -type l \( -perm /111 -exec chmod 755 {} \; -o -exec chmod 644 {} \; \) || die

	# Needs to be done before generating cacerts
	java-vm_set-pax-markings "${ddest}"

	# We need to generate keystore - bug #273306
	einfo "Generating cacerts file from certificates in ${EPREFIX}/usr/share/ca-certificates/"
	mkdir "${T}/certgen" && cd "${T}/certgen" || die
	cp "${FILESDIR}/generate-cacerts.pl" . && chmod +x generate-cacerts.pl || die
	for c in "${EPREFIX}"/usr/share/ca-certificates/*/*.crt; do
		openssl x509 -text -in "${c}" >> all.crt || die
	done
	./generate-cacerts.pl "${ddest}/bin/keytool" all.crt || die
	cp -vRP cacerts "${ddest}/jre/lib/security/" || die
	chmod 644 "${ddest}/jre/lib/security/cacerts" || die

	# OpenJDK7 should be able to use fontconfig instead, but wont hurt to
	# install it anyway. Bug 390663
	cp "${FILESDIR}"/fontconfig.Gentoo.properties.src "${T}"/fontconfig.Gentoo.properties || die
	eprefixify "${T}"/fontconfig.Gentoo.properties
	insinto "${dest}"/jre/lib
	doins "${T}"/fontconfig.Gentoo.properties

	set_java_env "${FILESDIR}/icedtea.env"
	if ! use X || ! use alsa || ! use cups; then
		java-vm_revdep-mask "${dest}"
	fi
	java-vm_sandbox-predict /proc/self/coredump_filter
}

pkg_preinst() {
	if has_version "<=dev-java/icedtea-7.2.0:7"; then
		# portage would preserve the symlink otherwise, related to bug #384397
		rm -f "${EROOT}/usr/lib/jvm/icedtea7"
		elog "To unify the layout and simplify scripts, the identifier of Icedtea-7*"
		elog "has changed from 'icedtea7' to 'icedtea-7' starting from version 7.2.0-r1"
		elog "If you had icedtea7 as system VM, the change should be automatic, however"
		elog "build VM settings in /etc/java-config-2/build/jdk.conf are not changed"
		elog "and the same holds for any user VM settings. Sorry for the inconvenience."
	fi
}
