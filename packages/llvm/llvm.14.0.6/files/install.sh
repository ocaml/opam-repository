#!/bin/bash -ex

llvm_config="$1"
libdir="$2"
cmake="$3"
make="$4"
action="$5"

function filter_experimental_targets {
    sed 's/AVR//g' | sed 's/M68k//g' | sed 's/Nios2//g' | xargs
}

function llvm_build {
    cd llvm

    # Copy the required Common LLVM CMake modules to the source tree
    cp ../cmake/Modules/* cmake/

    mkdir "build-$1"
    cd "build-$1"

    "$cmake" \
        -DCMAKE_BUILD_TYPE="`"$llvm_config" --build-mode`" \
        -DLLVM_TARGETS_TO_BUILD="`"$llvm_config" --targets-built | filter_experimental_targets | sed 's/ /;/g'`" \
        -DLLVM_OCAML_EXTERNAL_LLVM_LIBDIR="`"$llvm_config" --libdir`" \
        -DBUILD_SHARED_LIBS=`[ $1 = "shared" ] && echo TRUE || echo FALSE` \
        -DLLVM_OCAML_OUT_OF_TREE=TRUE \
        -DLLVM_OCAML_INSTALL_PATH="${libdir}" \
        -DLLVM_OCAML_EXTERNAL_LLVM_LIBS="`"$llvm_config" --libs`" \
        ..
    $make ocaml_all

    cd ../..
}

function llvm_install {
  cd llvm
  if test -d "build-$1"; then
    cd "build-$1"

    "$cmake" -P bindings/ocaml/cmake_install.cmake

    mkdir "${libdir}"/llvm/$1
    mv "${libdir}"/llvm/*.cma "${libdir}"/llvm/$1
    mv "${libdir}"/llvm/*.cmxa "${libdir}"/llvm/$1
    mv "${libdir}"/llvm/llvm*.a "${libdir}"/llvm/$1

    cd ..
  fi
  cd ..
}

case "$action" in
"build")
  if "$llvm_config" --link-static --libs && "$llvm_config" --link-shared --libs; then
    patch -p1 < META.patch
    llvm_build static
    llvm_build shared
  elif "$llvm_config" --link-static --libs; then
    sed "s,%%LINKAGE%%,static," link-META.patch | patch -p1
    llvm_build static
  elif "$llvm_config" --link-shared --libs; then
    sed "s,%%LINKAGE%%,shared," link-META.patch | patch -p1
    llvm_build shared
  else
    echo "Link mode not recognized"
    exit 1
  fi
  ;;
"install")
  llvm_install static
  llvm_install shared
  ;;
*)
  echo "Action not recognized"
  exit 1
  ;;
esac
