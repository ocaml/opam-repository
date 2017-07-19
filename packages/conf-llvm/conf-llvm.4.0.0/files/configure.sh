#!/bin/bash -ex

version=${1/%.?/}

if hash brew 2>/dev/null; then
    brew_llvm_config="$(brew --cellar)"/llvm/${version}*/bin/llvm-config
fi

shopt -s nullglob
for llvm_config in llvm-config-$version llvm-config${version//./} llvm-config-mp-$version $brew_llvm_config llvm-config; do
    llvm_version="`$llvm_config --version`"
    case $llvm_version in
    $version*)
        echo "config: \"$llvm_config\"" >> conf-llvm.config
        echo "version: \"$llvm_version\"" >> conf-llvm.config
        exit 0;;
    *)
        continue;;
    esac
done

echo "Error: LLVM ${version} is not installed."
exit 1
