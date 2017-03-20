#!/bin/bash -ex

version=${1/%.?/}
libdir=$2

function llvm_save {
    cp cmake/modules/AddOCaml.cmake AddOCaml.cmake.save
}

function llvm_restore {
    cp AddOCaml.cmake.save cmake/modules/AddOCaml.cmake
}

function llvm_install {
    patch -p1 < $1-link.patch

    mkdir build
    cd build

    cmake -DLLVM_OCAML_OUT_OF_TREE=TRUE -DLLVM_OCAML_INSTALL_PATH="${libdir}" ..
    make ocaml_all
    make -C bindings/ocaml install/fast

    cd ..

    mkdir $1
    cp "${libdir}"/llvm/*.a $1
    mv "${libdir}"/llvm/*.cma $1
    mv "${libdir}"/llvm/*.cmxa $1

    rm -rf build

    llvm_restore
}

if hash brew 2>/dev/null; then
    brew_llvm_config="$(brew --cellar)"/llvm/${version}*/bin/llvm-config
fi

shopt -s nullglob
for llvm_config in llvm-config-$version llvm-config${version//./} llvm-config-mp-$version ${brew_llvm_config} llvm-config; do
    case `$llvm_config --version` in
        $version*)
            shopt -u nullglob
            llvm_libdir=$($llvm_config --libdir)
            sed -i.bak "s,%%LIBDIR%%,${llvm_libdir}," static-link.patch
            llvm_save
            llvm_install static
            llvm_install dynamic
            mv static "${libdir}"/llvm
            mv dynamic "${libdir}"/llvm
            exit 0;;
        *)
            continue;;
    esac
done

echo "Error: LLVM ${version} is not installed."
exit 1
