#!/bin/bash -ex

version=${1/%.?.?/}

if hash brew 2>/dev/null; then
    brew_llvm_config="$(brew --cellar)"/llvm*/${version}*/bin/llvm-config
fi

shopt -s nullglob
for llvm_config in llvm-config-$version llvm-config-${version}.0 llvm-config${version}0 llvm-config-mp-$version llvm-config-mp-${version}.0 llvm${version}-config llvm-config-${version}-32 llvm-config-${version}-64 llvm-config $brew_llvm_config; do
    llvm_version="`$llvm_config --version`" || true
    case $llvm_version in
    $version*)
        echo "config: \"$(command -v '$llvm_config')\"" >> conf-llvm.config
        echo "version: \"$llvm_version\"" >> conf-llvm.config
        exit 0;;
    *)
        echo "Note: '$llvm_config' doesn't match the required version. Got '$llvm_version' but required '$version'."
        continue;;
    esac
done

echo "Error: LLVM ${version} is not installed."
exit 1
