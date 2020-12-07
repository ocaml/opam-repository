#!/bin/sh -eux

PREFIX=$1
MAKE=$2
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PKG_CONFIG_PATH

# WARNING: if you pass invalid cflags here, zarith will silently
# fall back to compiling with the default flags instead!
CFLAGS="$(pkg-config --cflags gmp-freestanding ocaml-freestanding)" \
LDFLAGS="$(pkg-config --libs gmp-freestanding)" \
CC=cc \
./configure -nodynlink -gmp

$MAKE
