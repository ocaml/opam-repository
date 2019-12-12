#!/bin/sh -eux

PREFIX=`opam config var prefix`
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PKG_CONFIG_PATH

cp libzarith.a "$PREFIX/lib/zarith/libzarith-freestanding.a"
cp zarith.cma  "$PREFIX/lib/zarith/zarith-freestanding.cma"
cp zarith.cmxa "$PREFIX/lib/zarith/zarith-freestanding.cmxa"

cat >>"$PREFIX/lib/zarith/META" <<EOM
freestanding_linkopts = "-lzarith-freestanding -L@gmp-freestanding -lgmp-freestanding"

package "freestanding" (
  requires = "ocaml-freestanding gmp-freestanding"
  archive(byte) = "zarith-freestanding.cma"
  archive(native) = "zarith-freestanding.cmxa"
)
EOM
