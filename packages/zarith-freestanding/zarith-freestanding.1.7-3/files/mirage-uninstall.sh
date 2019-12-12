#!/bin/sh -eux

PREFIX=`opam config var prefix`

rm -f "$PREFIX/lib/zarith/libzarith-freestanding.a"

mv "$PREFIX/lib/zarith/META" "$PREFIX/lib/zarith/META.tmp"
cat "$PREFIX/lib/zarith/META.tmp" | grep -v freestanding_linkopts > "$PREFIX/lib/zarith/META"
rm -f "$PREFIX/lib/zarith/META.tmp"
