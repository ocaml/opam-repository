#!/bin/sh

if llvm-config-3.4 --version > /dev/null; then
    $1 -C bindings/ocaml build SYSTEM_LLVM_CONFIG=llvm-config-3.4
    $1 -C bindings/ocaml install SYSTEM_LLVM_CONFIG=llvm-config-3.4
elif  llvm-config-mp-3.4 --version > /dev/null; then
    $1 -C bindings/ocaml build SYSTEM_LLVM_CONFIG=llvm-config-mp-3.4
    $1 -C bindings/ocaml install SYSTEM_LLVM_CONFIG=llvm-config-mp-3.4
else
    echo "Error: LLVM is not installed."
    exit 1
fi
