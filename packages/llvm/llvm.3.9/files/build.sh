#!/bin/bash -ex

version=$1
libdir=$2

brew_llvm_config=/usr/local/Cellar/llvm/${version}*/bin/llvm-config
if ! stat -t $brew_llvm_config; then
    brew_llvm_config=
fi

shopt -s nullglob

if command -v cmake3 > /dev/null; then
    cmake=cmake3
else
    cmake=cmake
fi

version_sans_dot=$(echo $version | tr -d .)
for llvm_config in llvm-config-$version llvm-config$version_sans_dot llvm-config-mp-$version $brew_llvm_config llvm-config; do
    case `$llvm_config --version` in
        $version|$version.*)
            case `$llvm_config --shared-mode` in
                "shared")
                    patch -p1 < link.patch;;
                "static")
                    ;;
                *)
                    echo "Error: '$llvm_config' should have returned either shared or static"
                    exit 1;;
            esac
            mkdir build
            cd build
            $cmake -DLLVM_OCAML_OUT_OF_TREE=TRUE -DLLVM_OCAML_INSTALL_PATH="$libdir" ..
            exit 0;;
        *)
            continue;;
    esac
done

echo "Error: LLVM $version is not installed."
exit 1
