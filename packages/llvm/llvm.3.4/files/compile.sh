#!/bin/sh

version=3.4
make=$1
prefix=$2
libdir=$3

brew_llvm_config=/usr/local/Cellar/llvm/${version}*/bin/llvm-config
if ! stat -t $brew_llvm_config
then
    brew_llvm_config=
fi

execute() {
    echo "Executing: $@"
    "$@"
}

common_configure() {
    execute ./configure CC=gcc CXX=g++ --prefix="$prefix" --disable-doxygen --disable-docs --enable-static "$@" --with-ocaml-libdir="$libdir/llvm"
}

for config in llvm-config-$version llvm-config-mp-$version $brew_llvm_config llvm-config; do
    case `"$config" --version` in
        $version|$version.*)
            case `uname -s` in
                Darwin)
                    common_configure --disable-shared || exit 1;;
                *)
                    common_configure --enable-shared || exit 1;;
            esac
            "$make" -C bindings/ocaml build SYSTEM_LLVM_CONFIG="$config" || exit 1
            "$make" -C bindings/ocaml install SYSTEM_LLVM_CONFIG="$config" || exit 1
            cp "$libdir/llvm/META.llvm" "$libdir/llvm/META" || exit 1
            exit 0;;
        *)
            continue;;
    esac
done

echo "Error: LLVM is not installed."
exit 1
