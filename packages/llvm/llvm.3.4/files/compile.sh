#!/bin/sh

cmd=$1
version=$2
make=$3
prefix=$4
libdir=$5

execute() {
    echo "Executing: $@"
    "$@"
}

common_configure() {
    execute ./configure CC=gcc CXX=g++ --disable-compiler-version-checks --prefix="$prefix" --disable-doxygen --disable-docs --enable-static "$@" --with-ocaml-libdir="$libdir/llvm"
}

configure() {
    case `uname -s` in
        Darwin)
            common_configure --disable-shared || exit 1;;
        *)
            common_configure --enable-shared || exit 1;;
    esac
}

if [ $cmd = "uninstall" ]; then
    configure
    "$make" -C bindings/ocaml -k uninstall || exit 1
    rm -rf "$libdir/llvm"
    exit 0
elif [ $cmd != "install" ]; then
    echo "Fatal error: Do not recognize the command"
    exit 1
fi

brew_llvm_config=/usr/local/Cellar/llvm/${version}*/bin/llvm-config
if ! stat -t $brew_llvm_config
then
    brew_llvm_config=
fi

version_sans_dot=$(echo $version | tr -d .)
for config in llvm-config-$version llvm-config$version_sans_dot llvm-config-mp-$version $brew_llvm_config llvm-config; do
    case `"$config" --version` in
        $version|$version.*)
            configure
            "$make" -C bindings/ocaml build SYSTEM_LLVM_CONFIG="$config" || exit 1
            "$make" -C bindings/ocaml install SYSTEM_LLVM_CONFIG="$config" || exit 1
            cp "$libdir/llvm/META.llvm" "$libdir/llvm/META" || exit 1
            exit 0;;
        *)
            continue;;
    esac
done

echo "Error: LLVM $version is not installed."
exit 1
