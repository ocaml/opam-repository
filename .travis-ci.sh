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

echo OCaml version
ocaml -version
echo OPAM versions
opam --version
opam --git-version

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

function opam_version_compat {
  local OPAM_MAJOR OPAM_MINOR ocamlv bytev
  if [ -n "$opam_version_compat_done" ]; then return; fi
  opam_version_compat_done=1
  OPAM_MAJOR=${OPAM_VERSION%%.*}
  OPAM_MINOR=${OPAM_VERSION#*.}
  OPAM_MINOR=${OPAM_MINOR%%.*}
  if [ $OPAM_MAJOR -eq 1 ] && [ $OPAM_MINOR -lt 2 ]; then
      opam_version_11=1
      ocamlv=$(ocamlrun -vnum)
      bytev=${ocamlv%.*}
      curl -L https://opam.ocaml.org/repo_compat_1_1.byte$bytev -o compat.byte
      ocamlrun compat.byte
  fi
}
opam_version_compat

function build_one {
  pkg=$1
  echo "build one: $pkg ($OPAM_SWITCH)"
  rm -rf ~/.opam
  if [ -n "${opam_version_11}" ]; then
      # Hide OCaml build log
      if opam init . --comp=$OPAM_SWITCH > build.log 2>&1 ; then
          echo -n
      else
          rc=$?
          cat build.log
          exit $rc
      fi
  else
      opam init . --comp=$OPAM_SWITCH
  fi
  eval `opam config env`
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
    case $TRAVIS_OS_NAME in
        linux)
            # we need fresh gcc and binutils, maybe...
            # this can soon be removed, once travis upgraded their infrastructure
            if [ `opam install --dry-run $pkg | grep -c mirage-entropy-xen` -gt 0 ] ; then
                echo "installing a recent gcc and binutils (mainly to get mirage-entropy-xen working\!)"
                sudo add-apt-repository --yes ppa:ubuntu-toolchain-r/test
                sudo apt-get -qq update
                sudo apt-get install -y gcc-4.8
                sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 90
                wget http://mirrors.kernel.org/ubuntu/pool/main/b/binutils/binutils_2.24-5ubuntu3.1_amd64.deb
                sudo dpkg -i binutils_2.24-5ubuntu3.1_amd64.deb
            fi
    esac
    echo
    echo "====== External dependency handling ======"
    opam install depext
    depext=$(opam depext -ls $pkg --no-sources)
    opam depext $pkg
    opam remove depext -a
    echo
    echo "====== Installing package ======"
    opam install $pkg
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

for i in `cat tobuild.txt`; do
  build_one $i
done

kill $PING_LOOP_PID
