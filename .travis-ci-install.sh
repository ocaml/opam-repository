wget https://raw.githubusercontent.com/ocaml/ocaml-ci-scripts/master/.travis-ocaml.sh

export BASE_REMOTE="."
bash -ex .travis-ocaml.sh
