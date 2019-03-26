#!/bin/bash -ex

llvm_config="$1"
libdir="$2"
cmake="$3"
make="$4"

function filter_experimental_targets {
    sed 's/AVR//g' | sed 's/Nios2//g' | sed 's/WebAssembly//g' | xargs
}

function llvm_install {
    mkdir build
    cd build

    "$cmake" \
        -DCMAKE_BUILD_TYPE="`"$llvm_config" --build-mode`" \
        -DLLVM_TARGETS_TO_BUILD="`"$llvm_config" --targets-built | filter_experimental_targets | sed 's/ /;/g'`" \
        -DLLVM_OCAML_EXTERNAL_LLVM_LIBDIR="`"$llvm_config" --libdir`" \
        -DBUILD_SHARED_LIBS=`[ $1 = "shared" ] && echo TRUE || echo FALSE` \
        -DLLVM_OCAML_OUT_OF_TREE=TRUE \
        -DLLVM_OCAML_INSTALL_PATH="${libdir}" \
        ..
    $make ocaml_all
    "$cmake" -P bindings/ocaml/cmake_install.cmake

    mkdir "${libdir}"/llvm/$1
    mv "${libdir}"/llvm/*.cma "${libdir}"/llvm/$1
    mv "${libdir}"/llvm/*.cmxa "${libdir}"/llvm/$1
    mv "${libdir}"/llvm/llvm*.a "${libdir}"/llvm/$1

    cd ..
    rm -rf build
}

if "$llvm_config" --link-static --libs && "$llvm_config" --link-shared --libs; then
    patch -p1 < META.patch
    llvm_install static
    llvm_install shared
elif "$llvm_config" --link-static --libs; then
    sed "s,%%LINKAGE%%,static," link-META.patch | patch -p1
    llvm_install static
elif "$llvm_config" --link-shared --libs; then
    sed "s,%%LINKAGE%%,shared," link-META.patch | patch -p1
    llvm_install shared
else
    echo "WTF..."
    exit 1
fi
