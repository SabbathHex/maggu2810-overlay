# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Tool to transform PC multimedia file(s) in any format, into a DVD complete with menus & suitable for playback on a standalone DVD player"
HOMEPAGE="http://any2dvd.sourceforge.net"

SRC_URI="http://dev.olausson.de/any2dvd/orig/${PF}.sh http://dev.olausson.de/any2dvd/orig/${PF/dvd/vob}.sh"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dv matroska mpegts mythtv ogg pcm X win32codecs real"

DEPEND=">=app-arch/sharutils-4.2.1
	>=net-misc/wget-1.9.1
	>=media-sound/sox-13.0.0
	media-fonts/gnu-gs-fonts-std
	media-fonts/gnu-gs-fonts-other
	>=media-video/ffmpeg-0.4.9_p20061016
	>=media-video/transcode-1.0.2
	>=media-gfx/imagemagick-6.3.5.10
	>=media-video/dvdauthor-0.6.11
	>=app-cdr/dvd+rw-tools-6.1
	>=media-video/mplayer-1.0_pre8
	>=media-video/mpgtx-1.3.1
	>=media-video/mjpegtools-1.6.2
	>=media-libs/a52dec-0.7.4
	>=media-libs/libsndfile-1.0.11
	>=media-sound/ecasound-2.4.1
	>=media-sound/multimux-0.2.3
	>=media-libs/libsoundtouch-1.3.0
	dts? ( || ( media-libs/libdca >=media-libs/libdts-0.0.2 ) )
	dv? ( >=media-libs/libdv-1.0.0 )
	matroska? ( >=media-video/mkvtoolnix-1.4.2 )
	mpegts? ( >=media-video/replex-0.1.4 )
	mythtv? ( >=media-tv/mythtv-0.18.1 )
	ogg? ( >=media-sound/ogmtools-1.5 )
	pcm? ( >=media-sound/wav2lpcm-0.1 )
	X? ( >=x11-misc/xbindkeys-1.7.3 )"

RDEPEND="${DEPEND}"

pkg_setup() {
	if use dv; then
		if ! built_with_use media-video/transcode dv; then
			eerror "Transcode is missing 'dv' support. Please add"
			eerror "'dv' to your USE flags, and re-emerge media-video/transcode"
			die "Transcode needs dv support"
		fi

		if ! built_with_use media-video/mjpegtools dv; then
			eerror "Mjpegtools is missing 'dv' support. Please add"
			eerror "'dv' to your USE flags, and re-emerge media-video/mjpegtools"
			die "Mjpegtools needs dv support"
		fi
	fi

	## FFmpeg dependencies ##
	if ! built_with_use media-video/ffmpeg {a52,aac,encode}; then
		eerror "FFmpeg is missing 'a52,aac and encode' support. Please add"
		eerror "'a52,aac and encode' to your USE flags, and re-emerge media-video/ffmpeg"
		die "FFmpeg needs 'a52,aac and encode' support"
	fi

	## Transcode dependencies ##
	if ! built_with_use media-video/transcode {a52,mjpeg,mp3,mpeg,xvid}; then
		eerror "Transcode is missing 'a52,mjpeg,mp3,mpeg and xvid' support. Please add"
		eerror "'a52,mjpeg,mp3,mpeg and xvid' to your USE flags, and re-emerge media-video/transcode"
		die "Transcode needs 'a52,mjpeg,mp3,mpeg and xvid' support"
	fi

	## Imagemagick dependencies ##
	if ! built_with_use media-gfx/imagemagick {jpeg,png,gs}; then
		eerror "Imagemagick is missing 'jpeg, png, gs' support. Please add"
		eerror "'jpeg, png, gs' to your USE flags, and re-emerge media-gfx/imagemagick"
		die "Imagemagick needs 'jpeg and png' support"
	fi

	## Mjpegtools dependencies ##
	if ! built_with_use media-video/mjpegtools png; then
		eerror "Mjpegtools is missing 'png' support. Please add"
		eerror "'png' to your USE flags, and re-emerge media-video/mjpegtools"
		die "Mjpegtools needs png support"
	fi

	## MPlayer dependencies ##
	if ! built_with_use media-video/mplayer {aac,dts,dv,encode,jpeg,mad,png,vorbis,x264}; then
		eerror "Mplayer is missing 'aac,dts,dv,encode,jpeg,mad,png,vorbis and x264' support. Please add"
		eerror "'aac,dts,dv,encode,jpeg,mad,png,vorbis and x264' to your USE flags, and re-emerge media-video/mplayer"
		die "Mplayer needs 'aac,dts,dv,encode,jpeg,mad,png,vorbis and x264' support"
	fi
	if use real && ! built_with_use media-video/mplayer real; then
		eerror "MPlayer is missing RealPlayer support, but USE=real is enabled."
		eerror "Mplayer must either be re-emerged with USE=real or re-emerge this eubild"
		eerror "without USE=real."
		eerror "Note installing RealPlayer may require a full X11 installation (depending on the arch)."
		die "RealPlayer support unavaiable and USE=real set"
	fi
	if use win32codecs; then
		if use amd64 || use ia64; then
			ewarn "'win32codecs' may cause binary incompatibilities on some 64-bit systems."
		fi
		if ! built_with_use media-video/mplayer win32codecs; then
			eerror "MPlayer is missing win32codecs support, but USE=win32codecs is enabled."
			eerror "Mplayer must either be re-emerged with USE=win32codecs or re-emerge this eubild without USE=win32codecs."
			die "win32codecs support unavaiable and USE=win32codecs set"
		fi
	fi
}

src_unpack() {
	cp ${DISTDIR}/${PF}.sh ${DISTDIR}/${PF/dvd/vob}.sh ${WORKDIR}
	epatch "${FILESDIR}/${PF}_imagemagic-6.3.5.10.patch"
	epatch "${FILESDIR}/${PF}_parameter-passing.patch"
	epatch "${FILESDIR}/${PF}_bitrate-workdir-feature.patch"
	epatch "${FILESDIR}/${PF/dvd/vob}_bitrate-workdir-feature.patch"
	epatch "${FILESDIR}/${PF/dvd/vob}_ps-grep.patch"
}

src_install() {
	newbin ${PF}.sh any2dvd || die "Faild to copy ${PF}.sh"
	newbin ${PF/dvd/vob}.sh any2vob || die "Faild to copy ${PF/dvd/vob}.sh"
}


pkg_postinst() {
	einfo "********************************************************************************"
	elog "I moved the files for the gentoo build to my own Server cause"
	elog "the author of this tool is not using version numbers on his beta"
	elog "so patches and digest may fail cause the file was change"
	elog "Check the following URLs for the bleeding edge changes/updates:"
	elog "http://mightylegends.org/downloads/${PF}.sh and"
	elog "http://mightylegends.org/downloads/${PF/dvd/vob}.sh"
	elog "http://sourceforge.net/mailarchive/forum.php?forum_name=any2dvd-users"
	einfo "This beta is so far released without "any2windows_video" if you need it,"
	einfo "extract it from the stable package and put it in /usr/bin/"
	einfo "********************************************************************************"
}
