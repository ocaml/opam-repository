#!/bin/sh -eux

PREFIX=`opam config var prefix`
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PKG_CONFIG_PATH

cp libzarith.a "$PREFIX/lib/zarith/libzarith-freestanding.a"

# This is a hack to get freestanding_linkopts into the host 'zarith' package.
cat >>"$PREFIX/lib/zarith/META" <<EOM
freestanding_linkopts = "-lzarith-freestanding -L@gmp-freestanding -lgmp-freestanding"
EOM
