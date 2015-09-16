wget https://raw.githubusercontent.com/ocaml/ocaml-travisci-skeleton/master/.travis-ocaml.sh

export OPAM_INIT=false
bash -ex .travis-ocaml.sh
