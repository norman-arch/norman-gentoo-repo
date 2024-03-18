# Copyright 2020-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker desktop xdg

DESCRIPTION="Wechat Universal"
HOMEPAGE="https://www.chinauos.com/resource/download-professional"

KEYWORDS="~amd64"

SRC_URI="
	amd64? ( https://home-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.wechat/com.tencent.wechat_${PV}_amd64.deb )
"
SLOT="0"
RESTRICT="bindist mirror strip binchecks"
LICENSE="Tencent"

# the sonames are gathered with the following trick
#
# objdump -p /path/weixin | grep NEEDED | awk '{print $2}' | xargs equery b | sort | uniq

RDEPEND="
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	sys-apps/dbus
	app-arch/bzip2
	sys-libs/zlib
	sys-libs/glibc
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X]
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libdrm
	x11-libs/libxkbcommon
	x11-libs/libxshmfence
	x11-libs/pango
	sys-apps/lsb-release
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-wm
	x11-libs/libxcb
	sys-apps/bubblewrap
	|| (
		dev-libs/openssl-compat:1.1.1
		=dev-libs/openssl-1.1.1*
	)
"
DEPEND="${RDEPEND}
        >=dev-util/patchelf-0.10
"
S="${WORKDIR}"

QA_PREBUILT="*"

src_prepare() {
	default

	patchelf --set-soname libbz2.so.1.0 \
		"${S}/opt/apps/com.tencent.wechat/files/wechat" || die
}

src_install() {
	newmenu "${FILESDIR}"/wechat-uos.desktop wechat-uos.desktop
	dobin "${FILESDIR}/wechat-uos"

	for size in 16 32 48 64 128 256; do
		doicon -s ${size} "${S}"/opt/apps/com.tencent.wechat/entries/icons/hicolor/${size}x${size}/apps/com.tencent.wechat.png
	done

	insinto /opt/wechat-uos
	doins -r "${S}"/opt/apps/com.tencent.wechat/files/*
	fperms +x /opt/wechat-uos/*
	fperms +x /opt/wechat-uos/RadiumWMPF/{host,runtime}/*
	fperms +x /opt/wechat-uos/RadiumWMPF/runtime/locales/*

	insinto /usr/share/wechat-uos/etc
	doins "${FILESDIR}"/license/etc/{lsb,os}-release

	insinto /usr/lib/license
	doins "${S}"/opt/apps/com.tencent.wechat/files/libuosdevicea.so

	insinto /usr/share/wechat-uos/var/uos
	newins "${FILESDIR}/license/var/uos/license.key" .license.key

	insinto /usr/share/wechat-uos/var/lib/uos-license
	newins "${FILESDIR}/license/var/lib/uos-license/license.json" .license.json

	insinto /usr/lib/wechat-uos
        newins "${FILESDIR}/open.sh" open
	fperms +x /usr/lib/wechat-uos/open
}
