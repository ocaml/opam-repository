#!/bin/bash -ex

llvm_config="$1"
libdir="$2"
cmake="$3"

case `"$llvm_config" --shared-mode` in
"shared")
    patch -p1 < link.patch;;
"static")
    ;;
*)
    echo "Error: '$llvm_config' should have returned either shared or static"
    exit 1;;
esac

mkdir build
cd build

"$cmake" -DLLVM_OCAML_OUT_OF_TREE=TRUE -DLLVM_OCAML_INSTALL_PATH="$libdir" ..
