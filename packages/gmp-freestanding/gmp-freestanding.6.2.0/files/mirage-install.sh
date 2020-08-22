#!/bin/sh -ex
if [ -z "$PREFIX" ]; then
	PREFIX=`opam config var prefix`
fi
PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig
LIBDIR=${PREFIX}/lib/gmp-freestanding

mkdir -p ${PKG_CONFIG_PATH}
cp gmp-freestanding.pc ${PKG_CONFIG_PATH}
mkdir -p ${LIBDIR}
cp .libs/libgmp.a ${LIBDIR}/libgmp-freestanding.a
touch ${LIBDIR}/META
mkdir -p ${LIBDIR}/include
cp gmp.h ${LIBDIR}/include
