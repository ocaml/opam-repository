#!/bin/sh

version=3.4

for config in llvm-config-$version llvm-config-mp-$version llvm-config; do
    case `$config --version` in
        $version|$version.*)
            $1 -C bindings/ocaml build SYSTEM_LLVM_CONFIG=$config
            $1 -C bindings/ocaml install SYSTEM_LLVM_CONFIG=$config
            exit 0;;
        *)
            continue;;
    esac
done

echo "Error: LLVM is not installed."
exit 1
