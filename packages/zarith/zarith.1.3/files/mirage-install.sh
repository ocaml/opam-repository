#!/bin/sh -eux

PREFIX=`opam config var prefix`
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PKG_CONFIG_PATH

if pkg-config --exists mirage-xen; then
  LDFLAGS=`pkg-config --libs gmp-xen`
  export LDFLAGS

  make clean
  # WARNING: if you pass invalid cflags here, zarith will silently
  # fall back to compiling with the default flags instead!
  CFLAGS="`pkg-config --cflags gmp-xen mirage-xen` -O2 -pedantic -fomit-frame-pointer -fno-builtin"
  export CFLAGS
  ./configure
  make
  cp libzarith.a "$PREFIX/lib/zarith/libzarith-xen.a"
fi
