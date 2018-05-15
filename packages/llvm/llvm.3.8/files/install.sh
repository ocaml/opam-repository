#!/bin/bash -ex

llvm_config="$1"
make="$2"
prefix="$3"
libdir="$4"

common_configure() {
    ../configure CC=gcc CXX=g++ --disable-compiler-version-checks --prefix="$prefix" \
        --disable-doxygen --disable-docs --with-ocaml-libdir="$libdir/llvm" \
        --enable-static --with-python="`command -v python2.7`" "$@"
}

configure() {
    case `uname -s` in
        Darwin)
            common_configure --disable-shared;;
        *)
            common_configure --enable-shared;;
    esac
}

mkdir build
cd build

configure

"$make" -C bindings all SYSTEM_LLVM_CONFIG="$llvm_config"
"$make" -C bindings install SYSTEM_LLVM_CONFIG="$llvm_config"

mv "$libdir/llvm/META.llvm" "$libdir/llvm/META"
shopt -s nullglob
for stublib in $libdir/llvm/dll*.so; do
    mv "$stublib" "$libdir/stublibs/"
    echo llvm > "$libdir/stublibs/$(basename $stublib).owner"
done
