# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Linux ATI TV Out support program"
HOMEPAGE="http://www.stud.uni-hamburg.de/users/lennart/projects/atitvout/"
SRC_URI="http://www.stud.uni-hamburg.de/users/lennart/projects/atitvout/${P}.tar.gz
	 mirror://gentoo/${P}-patches.tar.bz2"
IUSE=""
KEYWORDS="~x86"
SLOT="0"
LICENSE="GPL-2"

DEPEND="virtual/libc
	sys-libs/lrmi"

S=${WORKDIR}/${PN}
PATCHDIR=${WORKDIR}/patch

src_unpack() {
	cd ${WORKDIR}
	unpack ${P}-patches.tar.bz2
	unpack ${A}

	cd ${S}
	EPATCH_SUFFIX="patch" epatch ${PATCHDIR}
}

src_compile() {
	emake CFLAGS="${CFLAGS}" || die "emake failed"
}

src_install() {
	dobin atitvout
	dodoc HARDWARE README
}
