# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"

PATCH_VER="1.2"
UCLIBC_VER="1.0"

# Hardened gcc 4 stuff
PIE_VER="0.6.3"
SPECS_VER="0.2.0"
SPECS_GCC_VER="4.4.3"
# arch/libc configurations known to be stable with {PIE,SSP}-by-default
PIE_GLIBC_STABLE="x86 amd64 mips ppc ppc64 arm ia64"
PIE_UCLIBC_STABLE="x86 arm amd64 mips ppc ppc64"
SSP_STABLE="amd64 x86 mips ppc ppc64 arm"
# uclibc need tls and nptl support for SSP support
# uclibc need to be >= 0.9.33
SSP_UCLIBC_STABLE="x86 amd64 mips ppc ppc64 arm"
PIE_MUSL_STABLE="amd64 arm ppc mips x86"
SSP_MUSL_STABLE="amd64 arm ppc mips"
#end Hardened stuff

inherit eutils toolchain

KEYWORDS="amd64 ~arm ~mips x86"

RDEPEND=""
DEPEND="${RDEPEND}
	elibc_glibc? ( >=sys-libs/glibc-2.8 )
	>=${CATEGORY}/binutils-2.20"

if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.8 )"
fi

src_prepare() {
	if has_version '<sys-libs/glibc-2.12' ; then
		ewarn "Your host glibc is too old; disabling automatic fortify."
		ewarn "Please rebuild gcc after upgrading to >=glibc-2.12 #362315"
		EPATCH_EXCLUDE+=" 10_all_default-fortify-source.patch"
	fi

	toolchain_src_prepare

	if use elibc_musl || [[ ${CATEGORY} = cross-*-musl ]]; then
		epatch "${FILESDIR}"/${PN}-4.8.3-musl-res_state.patch
		epatch "${FILESDIR}"/${PN}-4.8.3-musl-fix-libc5-assumption.patch
		epatch "${FILESDIR}"/${PN}-4.8.5-posix_memalign.patch

		local EPATCH_EXCLUDE="gcc-ssp.diff vis_hide.diff"
		local EPATCH_SUFFIX="diff"
		local EPATCH_FORCE="yes"
		epatch ${FILESDIR}/musl-gcc-patches-${PV}
	fi

	use vanilla && return 0
	#Use -r1 for newer piepatchet that use DRIVER_SELF_SPECS for the hardened specs.
	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env-r1.patch
}
