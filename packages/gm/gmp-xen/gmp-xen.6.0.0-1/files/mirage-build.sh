#!/bin/sh -ex
if [ -z "$PREFIX" ]; then
	PREFIX="`opam config var prefix`/lib/gmp-xen"
fi

PKG_CONFIG_DEPS="mirage-xen-posix"
check_deps () {
  pkg-config --print-errors --exists ${PKG_CONFIG_DEPS}
}

if ! check_deps 2>/dev/null; then
  # rely on `opam` if deps are unavailable
  export PKG_CONFIG_PATH="`opam config var prefix`/lib/pkgconfig"
fi
check_deps || exit 1

CPPFLAGS="$CPPFLAGS `pkg-config $PKG_CONFIG_DEPS --cflags` -O2 -pedantic -fomit-frame-pointer -fno-builtin -D_FORTIFY_SOURCE=0 -Wmissing-prototypes --std=gnu99"
# Use different --host and --build to trigger cross-compilation mode (don't try to test binaries during configure)
# Set CC to stop it trying to find a separate compiler for HOST.
# Pass CPPFLAGS (not just CFLAGS) to stop it finding the Linux headers (just generates warnings).
# Use -Werror=missing-prototypes because we're not running the tests due to cross-compiling.
HOST="`uname -m`-unknown-none"
BUILD=`./config.guess`
./configure --host="$HOST" --build="$BUILD" --enable-fat CC=gcc --prefix="$PREFIX" --disable-shared CPPFLAGS="$CPPFLAGS" --with-pic
# Because we're cross-compiling, configurate can't tell whether a function
# actually exists and just assumes they all do. For localeconv, this is wrong.
sed -e '/HAVE_LOCALECONV/d'  \
    -e '/HAVE_OBSTACK_VPRINTF/d'\
    -i config.status
./config.status
make
