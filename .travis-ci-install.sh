wget https://raw.githubusercontent.com/toots/ocaml-ci-scripts/master/.travis-ocaml.sh

export OPAM_INIT=false
bash -ex .travis-ocaml.sh
