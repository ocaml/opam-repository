VERSION=3.4

if `opam config var conf-llvm:installed` == "true"; then
    VERSION=`opam config var conf-llvm:version`
else
    VERSION=`opam config var conf-llvm:version`
fi

cat > plugins/x86/x86_llvm_config.ml.ab <<EOF
let llvm_version = "$VERSION"

EOF
