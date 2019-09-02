#!/bin/bash -ex

find_llvm_config () {
    # Locate llvm-config (taken from conf-llvm's configure.sh file)

    shopt -s nullglob
    for version in 7 6 5 4 3; do
        if hash brew 2>/dev/null; then
           brew_llvm_config="$(brew --cellar)"/llvm*/${version}*/bin/llvm-config
        fi
        for llvm_config in \
            llvm-config-$version llvm-config-${version}.0 \
            llvm-config${version}0 llvm-config-mp-$version \
            llvm-config-mp-${version}.0 $brew_llvm_config \
            llvm-config; do
            llvm_version="`$llvm_config --version`" || continue
            return
        done
    done

    echo "Error: LLVM is not installed."
    exit 1
}

find_llvm_config

LLVM_CFLAGS="`\"$llvm_config\" --cflags`"
LLVM_LDFLAGS="`\"$llvm_config\" --ldflags`"
LLVM_LIBDIR="`\"$llvm_config\" --libdir`"

# These filters enable compilation with gcc.
# Filter -Wstring-conversion for OpenSUSE
LLVM_CFLAGS="`echo $LLVM_CFLAGS | sed s/-Wstring-conversion\\ //`"

# Filter -Werror=unguarded-availability-new and -Wcovered-switch-default
# (which appear with LLVM 7)
LLVM_CFLAGS="`echo $LLVM_CFLAGS | sed s/-Werror=unguarded-availability-new\\ //`"
LLVM_CFLAGS="`echo $LLVM_CFLAGS | sed s/-Wcovered-switch-default\\ //`"

# Filter "-Wdelete-non-virtual-dtor" (warning only)
LLVM_CFLAGS="`echo $LLVM_CFLAGS | sed s/-Wdelete-non-virtual-dtor\\ //`"

tempdir="`mktemp -d`"

clean_tempdir () {
    rm -f "$tempdir/test_libclang.c" "$tempdir/test_libclang.o" \
       "$tempdir/test_libclang"
    rmdir "$tempdir"
}

cat >"$tempdir/test_libclang.c" <<EOF
#include <clang-c/Index.h>
#include <stdlib.h>

int
main(int argc, char *argv[])
{
  CXIndex idx = clang_createIndex(1, 1);
  clang_disposeIndex(idx);
  return EXIT_SUCCESS;
}
EOF
CC=cc
"$CC" -o "$tempdir/test_libclang.o" -c $LLVM_CFLAGS \
    "$tempdir/test_libclang.c" || \
    ( clean_tempdir; echo "Error: cannot compile libclang test."; exit 1 )
"$CC" -o "$tempdir/test_libclang" \
    $LLVM_LDFLAGS "$tempdir/test_libclang.o" \
    "-lclang" "-Wl,-rpath,$LLVM_LIBDIR" || \
    ( clean_tempdir; echo "Error: cannot link libclang test."; exit 1 )
"$tempdir/test_libclang" || \
    ( clean_tempdir; echo "Error: cannot execute libclang test."; exit 1 )
clean_tempdir
