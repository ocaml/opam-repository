#!/usr/bin/env sh

cc=$(ocamlc -config | awk '/^bytecomp_c_compiler/ {$1="";sub(/^ /, ""); print}')
$cc $CFLAGS test.c ${LACAML_LIBS:--lblas}
