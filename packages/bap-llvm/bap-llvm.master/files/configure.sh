
#!/bin/bash -ex

env_config=${LLVM_CONFIG}

versions="\
3.4 \
3.8 \
4.0 \
"
if hash brew 2>/dev/null; then
    brew_llvm_config="$(brew --cellar)"/llvm*/${version}*/bin/llvm-config
fi

shopt -s nullglob

for version in $versions; do

    llvm_configs="\
$env_config \
llvm-config-$version \
llvm-config${version//./} \
llvm-config-mp-$version \
$brew_llvm_config \
llvm-config \
"
    for llvm_config in $llvm_configs; do

        llvm_version="`$llvm_config --version`" || true
        case $llvm_version in
            $version*)
                echo "config: \"$llvm_config\"" >> bap-llvm.config
                echo "version: \"$llvm_version\"" >> bap-llvm.config
                exit 0;;
            *)
                echo "Note: '$llvm_config' doesn't match the required version. Got '$llvm_version' but required '$version'."
                continue;;
        esac
    done

done

echo "Error: none of LLVM ${versions} is installed."
exit 1
