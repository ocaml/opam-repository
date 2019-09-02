#!/bin/sh -ex
if [ -z "$PREFIX" ]; then
	PREFIX=`opam config var prefix`
fi
LIBDIR="$PREFIX/lib/gmp-xen"
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PKG_CONFIG_PATH

make install
mkdir -p "$PKG_CONFIG_PATH"
cp gmp-xen.pc "$PKG_CONFIG_PATH/"
mkdir -p "$LIBDIR"
cp .libs/libgmp.a "$LIBDIR/libgmp-xen.a"
