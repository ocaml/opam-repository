#!/bin/sh -ex
PREFIX=`opam config var prefix`
LIBDIR="$PREFIX/lib/gmp-xen"
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PKG_CONFIG_PATH

make install
mkdir -p "$PKG_CONFIG_PATH"
cp gmp-xen.pc "$PKG_CONFIG_PATH/"
mkdir -p "$LIBDIR"
cp .libs/libgmp.a "$LIBDIR/libgmp-xen.a"
