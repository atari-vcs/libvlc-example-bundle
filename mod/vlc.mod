#!/bin/bash

set -e
set -x

apt-get install -y --no-install-recommends git automake autopoint \
        gettext libtool flex bison libogg-dev lua5.2 liblua5.2-dev \
        nasm libxcb-composite0-dev libxcb-xv0-dev libxcb-randr0-dev \
        cmake python3-pip libltdl-dev libsdl2-dev libva-dev \
        libgmp3-dev nettle-dev libgnutls-dev

pip3 install --upgrade --system meson

mkdir -p /build/src

if [ ! -d /build/src/protobuf-3.1.0 ]; then
    cd /build/src
    wget -c -nv https://github.com/protocolbuffers/protobuf/releases/download/v3.1.0/protobuf-cpp-3.1.0.tar.gz
    tar xzf protobuf-cpp-3.1.0.tar.gz
fi

cd /build/src/protobuf-3.1.0
./configure --prefix=/usr
make -j$(nproc)
make install
ldconfig

if [ ! -d /build/src/vlc ]; then
    cd /build/src
    git clone -b 3.0.16 https://code.videolan.org/videolan/vlc.git
    cd /build/src/vlc

    export EMAIL='root@localhost'
    git am <<'EOF'
From 3d5aa69891fb9789ffb80be6b46d324b1932f2cf Mon Sep 17 00:00:00 2001
From: Ed Smith <ed.smith@collabora.com>
Date: Thu, 17 Feb 2022 07:43:22 +0000
Subject: [PATCH 1/3] Patch ffmpeg build options to use VAAPI and avoid asm

Using asm currently fails, because the produced code is not
relocatable, for unclear reasons. This eventually causes link
errors for libvlc.so.
---
 contrib/src/ffmpeg/rules.mak | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/contrib/src/ffmpeg/rules.mak b/contrib/src/ffmpeg/rules.mak
index 7966c653d6..27532fcdc2 100644
--- a/contrib/src/ffmpeg/rules.mak
+++ b/contrib/src/ffmpeg/rules.mak
@@ -153,7 +153,7 @@ endif
 
 # Linux
 ifdef HAVE_LINUX
-FFMPEGCONF += --target-os=linux --enable-pic --extra-libs="-lm"
+FFMPEGCONF += --target-os=linux --enable-pic --extra-libs="-lm" --disable-x86asm --enable-vaapi
 
 endif
 
-- 
2.35.1
EOF

    git am <<'EOF'
From 415a4b6765393bf51bb6c75e89ec213fb16312b4 Mon Sep 17 00:00:00 2001
From: Ed Smith <ed.smith@collabora.com>
Date: Thu, 17 Feb 2022 07:44:40 +0000
Subject: [PATCH 2/3] Detect if system libgmp is present

We are unable to use recent versions of libgmp, due to licensing.
The older versions lack pkg-config scripts, which in any case are
not tested for here: if any plugin that depends on GMP is built,
GMP is also built.

This patch just looks to see if a compatible .so file is present on
the system.
---
 contrib/src/gmp/rules.mak | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/contrib/src/gmp/rules.mak b/contrib/src/gmp/rules.mak
index 80acfc59cf..1a3a62a258 100644
--- a/contrib/src/gmp/rules.mak
+++ b/contrib/src/gmp/rules.mak
@@ -5,6 +5,10 @@ GMP_URL := https://gmplib.org/download/gmp-$(GMP_VERSION)/gmp-$(GMP_VERSION).tar
 
 GMP_CONF :=
 
+ifneq ($(and $(wildcard /usr/lib/x86_64-linux-gnu/libgmp.so.3),$(wildcard /usr/include/gmp.h)),)
+PKGS_FOUND += gmp
+endif
+
 ifeq ($(CC),clang)
 ifeq ($(ARCH),mipsel)
 GMP_CONF += --disable-assembly
-- 
2.35.1
EOF

    git am <<'EOF'
From 5594391f6b940568334992c3732bd769043037e2 Mon Sep 17 00:00:00 2001
From: Ed Smith <ed.smith@collabora.com>
Date: Thu, 17 Feb 2022 07:46:45 +0000
Subject: [PATCH 3/3] Fix gnutls contrib build

These two lines were lost at some point upstream, but make it
impossible to build gmp from the contrib folder in its current state,
because it won't be linked against enough libraries, and dependencies
are not automatically transitive in this build system.
---
 contrib/src/gnutls/rules.mak | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/contrib/src/gnutls/rules.mak b/contrib/src/gnutls/rules.mak
index 70bd94c64f..474b498ad2 100644
--- a/contrib/src/gnutls/rules.mak
+++ b/contrib/src/gnutls/rules.mak
@@ -37,6 +37,8 @@ gnutls: gnutls-$(GNUTLS_VERSION).tar.xz .sum-gnutls
 	# disable the dllimport in static linking (pkg-config --static doesn't handle Cflags.private)
 	cd $(UNPACK_DIR) && sed -i.orig -e s/"_SYM_EXPORT __declspec(dllimport)"/"_SYM_EXPORT"/g lib/includes/gnutls/gnutls.h.in
 
+	cd $(UNPACK_DIR) && sed -i.orig -e 's/@LIBATOMIC_LIBS@/@LIBATOMIC_LIBS@ @HOGWEED_LIBS@ @NETTLE_LIBS@/' lib/gnutls.pc.in
+
 	$(call pkg_static,"lib/gnutls.pc.in")
 	$(UPDATE_AUTOCONFIG)
 	$(MOVE)
-- 
2.35.1
EOF
fi

cd /build/src/vlc/contrib
if [ ! -f vlc-contrib-*.tar.bz2 ]; then
    mkdir -p native
    cd native
    mkdir -p /contrib-build
    ../bootstrap --disable-gpl --disable-gnuv3 --disable-bluray --prefix=/contrib-build
    make package
    cd ..
    rm -rf native
fi

mkdir -p /usr/src/vlc-contrib
cd /usr/src/vlc-contrib
tar xjf /build/src/vlc/contrib/vlc-contrib-*.tar.bz2 --strip-components=1
/build/src/vlc/contrib/src/change_prefix.sh '@@CONTRIB_PREFIX@@' '/usr'
cp -r * /usr
ldconfig

cd /build/src/vlc
./bootstrap
./configure --prefix=/usr --disable-vlc --enable-shared --disable-a52
make V=1 -j$(nproc)
make V=1 install
