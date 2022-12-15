#!/bin/bash -ex

clean_tempdir () {
    rm -f "$tempdir/test_libclang.c" "$tempdir/test_libclang.o" \
       "$tempdir/test_libclang"
    rmdir "$tempdir"
}

shopt -s nullglob
for version in default 13 12 11 10 9 8 7 6 5 4 3; do
    if [ "$version" = default ]; then
        llvm_config=llvm-config
        llvm_version="$($llvm_config --version)" || continue
        if [ $(printf "${llvm_version%%.*}\n14" | sort -n | head -n1) = 14 ]; then
            continue
        fi
    else
        if hash brew 2>/dev/null; then
           brew_llvm_config="$(brew --cellar)"/llvm*/${version}*/bin/llvm-config || true
           brew_llvm_config_at="$(brew --cellar)"/llvm@${version}/${version}*/bin/llvm-config || true
        fi
        for llvm_config in \
            llvm-config-${version} llvm-config-${version}.0 \
            llvm-config${version}0 llvm-config${version} \
            llvm-config-${version}-32 llvm-config-${version}-64 \
            llvm-config-mp-$version \
            llvm-config-mp-${version}.0 $brew_llvm_config $brew_llvm_config_at \
            /usr/lib64/llvm/${version}/bin/llvm-config \
            /usr/lib/llvm/${version}/bin/llvm-config \
            /usr/lib/llvm${version}/bin/llvm-config; do
            llvm_version="$($llvm_config --version)" || continue
            break
        done
        if [ -z "$llvm_version" ]; then
            continue
        fi
    fi

    LLVM_CFLAGS="$($llvm_config --cflags)"
    LLVM_LDFLAGS="$($llvm_config --ldflags)"
    LLVM_LIBDIR="$($llvm_config --libdir)"
    
    # These filters enable compilation with gcc.
    # Filter -Wstring-conversion for OpenSUSE
    LLVM_CFLAGS="$(echo $LLVM_CFLAGS | sed 's/-Wstring-conversion //')"
    
    # Filter -Werror=unguarded-availability-new and -Wcovered-switch-default
    # (which appear with LLVM 7)
    LLVM_CFLAGS="$(echo $LLVM_CFLAGS | sed 's/-Werror=unguarded-availability-new //')"
    LLVM_CFLAGS="$(echo $LLVM_CFLAGS | sed 's/-Wcovered-switch-default //')"
    
    # Filter "-Wdelete-non-virtual-dtor" (warning only)
    LLVM_CFLAGS="$(echo $LLVM_CFLAGS | sed 's/-Wdelete-non-virtual-dtor //')"

    tempdir="$(mktemp -d)"        
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
    if "$CC" -o "$tempdir/test_libclang.o" -c $LLVM_CFLAGS \
        "$tempdir/test_libclang.c" &&
      "$CC" -o "$tempdir/test_libclang" \
          $LLVM_LDFLAGS "$tempdir/test_libclang.o" \
          "-lclang" "-Wl,-rpath,$LLVM_LIBDIR" &&
      "$tempdir/test_libclang"; then
        true
    else
        clean_tempdir
        continue
    fi

    clean_tempdir
    
    echo "config: \"$llvm_config\"" >> conf-libclang.config
    echo "version: \"$llvm_version\"" >> conf-libclang.config
    exit 0
done

echo "Error: No usable version of LLVM <=13.0.x found."
exit 1

