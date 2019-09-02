VERSION=`opam config var conf-bap-llvm:package-version`

cat > plugins/x86/x86_llvm_config.ml.ab <<EOF
let llvm_version = "$VERSION"
EOF
