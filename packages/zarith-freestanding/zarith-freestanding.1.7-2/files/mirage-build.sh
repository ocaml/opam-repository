#!/bin/sh -eux

PREFIX=`opam config var prefix`
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PKG_CONFIG_PATH

# WARNING: if you pass invalid cflags here, zarith will silently
# fall back to compiling with the default flags instead!
CFLAGS="$(pkg-config --cflags gmp-freestanding ocaml-freestanding)" \
LDFLAGS="$(pkg-config --libs gmp-freestanding)" \
CC=cc \
./configure -nodynlink -gmp

if [ `uname -s` = "FreeBSD" ] || [ `uname -s` = "OpenBSD" ]; then
    gmake
else
    make
fi
