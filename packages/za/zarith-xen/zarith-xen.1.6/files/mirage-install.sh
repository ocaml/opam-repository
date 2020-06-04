#!/bin/sh -eux

PREFIX=`opam config var prefix`
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PKG_CONFIG_PATH

LDFLAGS=`pkg-config --libs gmp-xen`
export LDFLAGS

# WARNING: if you pass invalid cflags here, zarith will silently
# fall back to compiling with the default flags instead!
CFLAGS="`pkg-config --cflags gmp-xen mirage-xen-posix` -O2 -pedantic -fomit-frame-pointer -fno-builtin"
export CFLAGS
./configure
make

cp libzarith.a "$PREFIX/lib/zarith/libzarith-xen.a"

cat >>"$PREFIX/lib/zarith/META" <<EOM
xen_linkopts = "-lzarith-xen -L@gmp-xen -lgmp-xen"
EOM
