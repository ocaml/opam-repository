bash -c "while true; do echo \$(date) - building ...; sleep 360; done" &
PING_LOOP_PID=$!

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

function make_report {
    local errors=()
    local warnings=()
    for p in "$@"; do
        if ! opam lint packages/${p%%.*}/$p/opam >>"lint-report-$p"
        then errors+=($p)
        elif [ -s "lint-report-$p" ]; then warnings+=($p)
        else continue
        fi
        echo >>lint-report
        sed 's/^ \+\([^:]*\):\(.*\)$/- **\1**: \2/' "lint-report-$p" >> lint-report
    done
    if [ $# -eq 0 ]; then
        echo "This pull-request doesn't affect any packages"
        return
    elif [ ${#errors[@]} -eq 0 ] && [ ${#warnings[@]} -eq 0 ]; then
        echo "### :white_check_mark: All lint checks passed"
        echo "$*"
        return
    elif [ ${#errors[@]} -eq 0 ]; then
        echo "### :exclamation: opam-lint warnings (${warnings[*]})"
    else
        echo "### :x: opam-lint failure (${errors[*]})"
    fi
    cat lint-report
}

function opam_version_compat {
  local OPAM_MAJOR OPAM_MINOR ocamlv bytev
  if [ -n "$opam_version_compat_done" ]; then return; fi
  opam_version_compat_done=1
  OPAM_MAJOR=${OPAM_VERSION%%.*}
  OPAM_MINOR=${OPAM_VERSION#*.}
  OPAM_MINOR=${OPAM_MINOR%%.*}
  if [ $OPAM_MAJOR -eq 1 ] && [ $OPAM_MINOR -lt 2 ]; then
      ocamlv=$(ocamlrun -vnum)
      bytev=${ocamlv%.*}
      curl -L https://opam.ocaml.org/repo_compat_1_1.byte$bytev -o compat.byte
      ocamlrun compat.byte
  fi
}
opam_version_compat

function build_one {
  pkg=$1
  echo build one: $pkg
  rm -rf ~/.opam
  opam init .
  if [ "$OCAML_SWITCH" = "" ]; then
    echo Current switch is:
    opam switch
  else
    opam switch $OCAML_SWITCH
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

function push_pr_comment {
    [ -n "$TRAVIS_PULL_REQUEST" ] || return;
    echo "====== LINT REPORT ======"
    cat $1
    local json=$(python -c 'import json,sys; print json.dumps({"body":sys.stdin.read()})' <$1)
    local api_url="https://api.github.com/repos/$TRAVIS_REPO_SLUG/issues/$TRAVIS_PULL_REQUEST/comments"
    echo "==> Commenting back to GitHub PR ($api_url)"
    if [ -z "$OPAM_CI_TOKEN" ]; then
        echo "Err: GH token undefined"
        return 2
    fi
    curl -u "opam-ci:$OPAM_CI_TOKEN" "$api_url" -d "$json" || true
}

if [ $OCAML_VERSION = 4.02.1 ] &&
   [ $OPAM_VERSION = 1.2.2 ] &&
   [ $TRAVIS_OS_NAME = linux ]
then
    make_report $(cat tobuild.txt) >report.txt
    push_pr_comment report.txt
fi

for i in `cat tobuild.txt`; do
  build_one $i
done

kill $PING_LOOP_PID
