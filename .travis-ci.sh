bash -c "while true; do echo \$(date) - building ...; sleep 360; done" &
PING_LOOP_PID=$!

# generated during the install step
source .travis-ocaml.env

# display info about OS distribution and version
case $TRAVIS_OS_NAME in
osx) sw_vers ;;
*) cat /etc/*-release
   lsb_release -a
   uname -a
   cat /proc/version
   ;;
esac

echo OCAML_VERSION=$OCAML_VERSION
echo OPAM_SWITCH=$OPAM_SWITCH

echo pull req: $TRAVIS_PULL_REQUEST
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  curl -L https://github.com/$TRAVIS_REPO_SLUG/pull/$TRAVIS_PULL_REQUEST.diff -o pullreq.diff
else
  git show > pullreq.diff.tmp
  merge=`grep "^Merge: " pullreq.diff.tmp | awk -F: '{print $2}'`
  if [ "$merge" = "" ]; then
    echo Not a merge
    mv pullreq.diff.tmp pullreq.diff
  else
    echo Merge detected, extracting $merge diff
    git show $merge > pullreq.diff
  fi
fi

export OPAMYES=1

case $TRAVIS_OS_NAME in
osx) export OPAMFETCH=wget ;;
esac

cd $TRAVIS_BUILD_DIR
echo Pull request:
cat pullreq.diff
# CR: this will be replaced with the OCamlot analysis of affected packages
cat pullreq.diff | sed -E -n -e 's,\+\+\+ b/packages/[^/]*/([^/]*)/.*,\1,p' | sort -u > tobuild.txt
echo To Build:
cat tobuild.txt

function build_switch {
  rm -rf ~/.opam
  echo "build switch: $OPAM_SWITCH"
  opam init . --comp=$OPAM_SWITCH
  eval `opam config env`
}

function build_one {
  pkg=$1
  echo "build one: $pkg"
  # test for installability
  echo "Checking for availability..."
  if ! opam install $pkg --dry-run; then
      echo "Package unavailable."
      if opam show $pkg; then
          echo "Package is unavailable on this configuration, skipping:"
          opam install $pkg --dry-run || true
      else
          echo "ERROR: Package not found."
          echo "Maybe its definition failed to parse, check above."
          false
      fi
  else
    echo "... package available."
    echo
    echo "====== External dependency handling ======"
    opam install 'depext>=1.1.0'
    depext=$(opam depext -ls $pkg)
    opam depext $pkg
    echo
    echo "====== Installing dependencies ======"
    opam install --deps-only $pkg
    echo
    echo "====== Installing package ======"
    opam install -t -v $pkg
    opam remove -a ${pkg%%.*}
    if [ "$depext" != "" ]; then
      case $TRAVIS_OS_NAME in
      linux)
        sudo apt-get remove $depext
        sudo apt-get autoremove
        ;;
      osx)
        brew remove $depext
        ;;
      esac
    fi
  fi
}

build_switch

echo OCaml version
ocaml -version
echo OPAM versions
opam --version
opam --git-version

for i in `cat tobuild.txt`; do
    name=$(echo $i | cut -f1 -d".")
    case $name in
        ocaml|ocaml-base-compiler) ;;
        *) build_one $i
    esac
done

kill $PING_LOOP_PID
