#!/bin/bash -ex

version="3.4"

config=${LLVM_CONFIG}

if hash brew 2>/dev/null; then
    brew_llvm_config="$(brew --cellar)"/llvm*/${version}*/bin/llvm-config
fi

shopt -s nullglob
for llvm_config in $config llvm-config-$version llvm-config${version//./} llvm-config-mp-$version $brew_llvm_config llvm-config; do
    llvm_version="`$llvm_config --version`" || true
    case $llvm_version in
    $version*)
        echo "llvm_config: \"$llvm_config\"" >> conf-llvm-3_4.config
        echo "llvm_version: \"$llvm_version\"" >> conf-llvm-3_4.config
        exit 0;;
    *)
        echo "Note: '$llvm_config' doesn't match the required version. Got '$llvm_version' but required '$version'."
        continue;;
    esac
done

echo "Error: LLVM ${version} is not installed."
exit 1
