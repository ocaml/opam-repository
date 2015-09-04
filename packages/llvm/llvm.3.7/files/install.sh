#!/bin/bash -ex

version=$1
make=$2
prefix=$3
libdir=$4

common_configure() {
    ./configure CC=gcc CXX=g++ --disable-compiler-version-checks --prefix="$prefix" \
        --disable-doxygen --disable-docs --with-ocaml-libdir="$libdir/llvm" \
        --enable-static "$@"
}

configure() {
    case `uname -s` in
        Darwin)
            common_configure --disable-shared;;
        *)
            common_configure --enable-shared;;
    esac
}

brew_llvm_config=/usr/local/Cellar/llvm/${version}*/bin/llvm-config
if ! stat -t $brew_llvm_config; then
    brew_llvm_config=
fi

shopt -s nullglob

for config in llvm-config-$version llvm-config-mp-$version $brew_llvm_config llvm-config; do
    case `$config --version` in
        $version|$version.*)
            configure
            $make -C bindings/ocaml all SYSTEM_LLVM_CONFIG=$config
            $make -C bindings/ocaml install SYSTEM_LLVM_CONFIG=$config
            mv "$libdir/llvm/META.llvm" "$libdir/llvm/META"
            for stublib in $libdir/llvm/dll*.so; do
                mv "$stublib" "$libdir/stublibs/"
                echo llvm >"$libdir/stublibs/$(basename $stublib).owner"
            done
            exit 0;;
        *)
            continue;;
    esac
done

echo "Error: LLVM is not installed."
exit 1
