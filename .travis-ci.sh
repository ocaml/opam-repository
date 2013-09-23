echo pull req $TRAVIS_PULL_REQUEST

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  curl https://github.com/$TRAVIS_REPO_SLUG/pull/$TRAVIS_PULL_REQUEST.diff -o pullreq.diff
  cat pullreq.diff
fi

# Install OCaml and OPAM PPAs
case "$OCAML_VERSION" in
4.00.1)
  echo "yes" | sudo add-apt-repository ppa:avsm/ppa
  ;;
4.01.0)
  echo "yes" | sudo add-apt-repository ppa:avsm/ppa-testing
  ;;
*)
  ;;
esac

sudo apt-get update -qq
sudo apt-get install -qq ocaml ocaml-native-compilers camlp4-extra opam
export OPAMYES=1
export OPAMVERBOSE=1

cd $TRAVIS_BUILD_DIR
git show
