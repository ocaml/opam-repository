#!/bin/bash -ex

version=${1/%.?/}
libdir=$2

function llvm_save {
    cp cmake/modules/AddOCaml.cmake AddOCaml.cmake.save
}

function llvm_restore {
    cp AddOCaml.cmake.save cmake/modules/AddOCaml.cmake
}

function llvm_link_patch {
    llvm_libdir=$("$1" --libdir)
    llvm_libs=$("$1" --link-$2 --libs)

    sed -i.bak "s,%%LIBDIR%%,${llvm_libdir}," link.patch
    sed -i.bak "s,%%LIBS%%,${llvm_libs}," link.patch

    patch -p1 < link.patch
}

function llvm_install {
    llvm_link_patch "$2" $3

    mkdir build
    cd build

    cmake -DLLVM_OCAML_OUT_OF_TREE=TRUE -DLLVM_OCAML_INSTALL_PATH="${libdir}" ..
    make ocaml_all
    make -C bindings/ocaml install/fast

    cd ..

    mkdir "${libdir}"/llvm/$1
    cp "${libdir}"/llvm/*.a "${libdir}"/llvm/$1
    mv "${libdir}"/llvm/*.cma "${libdir}"/llvm/$1
    mv "${libdir}"/llvm/*.cmxa "${libdir}"/llvm/$1

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
            llvm_save
            if $llvm_config --link-static --libs && $llvm_config --link-shared --libs; then
                patch -p1 < META.patch
                llvm_install static "${llvm_config}" static
                llvm_install dynamic "${llvm_config}" shared
            elif $llvm_config --link-static --libs; then
                sed -i.bak "s,%%LINKAGE%%,static," link-META.patch
                patch -p1 < link-META.patch
                llvm_install static "${llvm_config}" static
            elif $llvm_config --link-shared --libs; then
                sed -i.bak "s,%%LINKAGE%%,dynamic," link-META.patch
                patch -p1 < link-META.patch
                llvm_install dynamic "${llvm_config}" shared
            else
                echo "WTF..."
                exit 1
            fi
            exit 0;;
        *)
            continue;;
    esac
done

echo "Error: LLVM ${version} is not installed."
exit 1
