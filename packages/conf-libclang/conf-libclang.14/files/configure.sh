#!/bin/bash -ex

clean_tempdir () {
    rm -f "$tempdir/test_libclang.c" "$tempdir/test_libclang.o" \
       "$tempdir/test_libclang"
    rmdir "$tempdir"
}

maximum_version=14

shopt -s nullglob
for version in default $(seq $maximum_version -1 3); do
    if [ "$version" = default ]; then
        for kind in system brew none; do
            case $kind in
            system)
                llvm_config=$(command -v llvm-config) || continue
                ;;
            brew)
                llvm_config="$(brew --prefix)/opt/llvm/bin/llvm-config" || continue
                ;;
            none)
                break
                ;;
            esac
            llvm_version="$($llvm_config --version)" || continue
            next_version=$((maximum_version + 1))
            if [\
                $(printf "${llvm_version%%.*}\n$next_version" | sort -n | head -n1)\
                    = $next_version ]; then
                continue
            fi
            break
        done
	if [ "$kind" == none ]; then
	    continue
	fi
    else
        if hash brew 2>/dev/null; then
           brew_llvm_config="$(brew --cellar llvm)"/${version}*/bin/llvm-config || true
           brew_llvm_config_at="$(brew --cellar llvm@${version})"/${version}*/bin/llvm-config || true
        fi
        llvm_version=""
        for llvm_config in \
            llvm-config-${version} llvm-config-${version}.0 \
            llvm-config${version}0 llvm-config${version} \
            llvm-config-${version}-32 llvm-config-${version}-64 \
            llvm-config-mp-$version \
            llvm-config-mp-${version}.0 $brew_llvm_config $brew_llvm_config_at \
            /usr/lib64/llvm/${version}/bin/llvm-config \
            /usr/lib/llvm/${version}/bin/llvm-config \
            /usr/lib/llvm${version}/bin/llvm-config; do
            llvm_config="$(command -v $llvm_config)" || continue
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
    checksum=
    for hasher in \
        "sha512:sha512sum" \
        "sha512:shasum -a 512" \
        "md5:md5sum" \
        "md5:md5 -q"; do
        hasher_output=$(${hasher#*:} "$llvm_config") || continue
        checksum="${hasher%%:*}=${hasher_output%% *}"
        break
    done
    if [ -z "$checksum" ]; then
        echo "Error: Unable to find a hasher"
        exit 1
    fi

    case "$llvm_version" in
    14*)
        clangml460_configure_options="--with-llvm-version=14.0.0" # clangml.4.4.0 does not recognize 14.0.x with x>=4
        ;;
    *)
        clangml460_configure_options="" # rely on clangml's ./configure autodetection
        ;;
    esac

    cat >"conf-libclang.config" <<EOF
opam-version: "2.0"
file-depends: [ "$llvm_config" "$checksum" ]
variables {
    config: "$llvm_config"
    version: "$llvm_version"
    clangml460_configure_options: "$clangml460_configure_options"
}
EOF
    exit 0
done

echo "Error: No usable version of LLVM <=14.0.x found."
exit 1
