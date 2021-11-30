#!/bin/sh -ex
if [ -z "$PREFIX" ]; then
	PREFIX="`opam config var prefix`/lib/gmp-freestanding"
fi

PKG_CONFIG_DEPS="ocaml-freestanding"
check_deps () {
  pkg-config --print-errors --exists ${PKG_CONFIG_DEPS}
}

if ! check_deps 2>/dev/null; then
  # rely on `opam` if deps are unavailable
  export PKG_CONFIG_PATH="`opam config var prefix`/lib/pkgconfig"
fi
check_deps || exit 1

#
# ocaml-freestanding does not provide a real cross compiler, so we fake it:
# 
# - set CC to stop configure trying to find a host compiler
# - set CPPFLAGS to ocaml-freestanding CFLAGS, this prevents inclusion of
#   system headers
# - manually override tests for missing functions
# - manually trim the components (SUBDIRS) of libgmp we build to the subset
#   actually used by zarith-freestanding (our sole dependency)
# - set -Werror=implicit-function-declaration at *build* time to catch any
#   undefined symbols
#
# Further, with the introduction of -fstack-protector-strong in Solo5, override
# this during './configure' to prevent it complaining that the compiler does not
# work, and reinstate it again during 'make'.
#
FREESTANDING_CFLAGS="$(pkg-config --cflags ${PKG_CONFIG_DEPS})"
ac_cv_func_obstack_vprintf=no \
ac_cv_func_localeconv=no \
./configure \
    --host=$(uname -m)-unknown-none --enable-fat --disable-shared --with-pic=no \
    CC=cc "CPPFLAGS=${FREESTANDING_CFLAGS} -fno-stack-protector"

make SUBDIRS="mpn mpz mpq mpf" \
    PRINTF_OBJECTS= SCANF_OBJECTS= \
    CPPFLAGS="${FREESTANDING_CFLAGS}" \
    CFLAGS+=-Werror=implicit-function-declaration
