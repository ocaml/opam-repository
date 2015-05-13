#!/bin/sh -ex
PREFIX=`opam config var prefix`
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PKG_CONFIG_PATH

CPPFLAGS="$CPPFLAGS `pkg-config mirage-xen-posix --cflags` -O2 -pedantic -fomit-frame-pointer -fno-builtin -D_FORTIFY_SOURCE=0 -Wmissing-prototypes --std=gnu99"
# Use different --host and --build to trigger cross-compilation mode (don't try to test binaries during configure)
# Set CC to stop it trying to find a separate compiler for HOST.
# Pass CPPFLAGS (not just CFLAGS) to stop it finding the Linux headers (just generates warnings).
# Use -Werror=missing-prototypes because we're not running the tests due to cross-compiling.
HOST="`uname -m`-unknown-none"
BUILD=`./config.guess`
./configure --host="$HOST" --build="$BUILD" CC=gcc --prefix="$PREFIX/lib/gmp-xen" --disable-shared CPPFLAGS="$CPPFLAGS"
# Because we're cross-compiling, configurate can't tell whether a function
# actually exists and just assumes they all do. For localeconv, this is wrong.
sed -e '/HAVE_LOCALECONV/d'  \
    -e '/HAVE_OBSTACK_VPRINTF/d'\
    -i config.status
./config.status
make
