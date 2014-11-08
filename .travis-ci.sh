echo pull req: $TRAVIS_PULL_REQUEST
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  curl https://github.com/$TRAVIS_REPO_SLUG/pull/$TRAVIS_PULL_REQUEST.diff -o pullreq.diff
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

full_apt_version () {
  package=$1
  version=$2
  echo -n "${package}="
  apt-cache show $package | sed -n "s/^Version: \(${version}\)/\1/p" | head -1
}

install_on_linux () {
  # Install OCaml and OPAM PPAs
  case "$OCAML_VERSION,$OPAM_VERSION" in
  3.12.1,1.0.0) ppa=avsm/ocaml312+opam10 ;;
  3.12.1,1.1.0) ppa=avsm/ocaml312+opam11 ;;
  3.12.1,1.2.0) ppa=avsm/ocaml312+opam12 ;;
  4.00.1,1.0.0) ppa=avsm/ocaml40+opam10 ;;
  4.00.1,1.1.0) ppa=avsm/ocaml40+opam11 ;;
  4.00.1,1.2.0) ppa=avsm/ocaml40+opam12 ;;
  4.01.0,1.0.0) ppa=avsm/ocaml41+opam10 ;;
  4.01.0,1.1.0) ppa=avsm/ocaml41+opam11 ;;
  4.01.0,1.2.0) ppa=avsm/ocaml41+opam12 ;;
  4.02.1,1.1.0) ppa=avsm/ocaml42+opam11 ;;
  4.02.1,1.2.0) ppa=avsm/ocaml42+opam12 ;;
  *) echo Unknown $OCAML_VERSION,$OPAM_VERSION; exit 1 ;;
  esac

  sudo add-apt-repository "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe"
  sudo add-apt-repository --yes ppa:$ppa
  sudo apt-get update -qq
  sudo apt-get install -y $(full_apt_version ocaml-compiler-libs $OCAML_VERSION) \
                          $(full_apt_version ocaml-interp $OCAML_VERSION) \
                          $(full_apt_version ocaml-base-nox $OCAML_VERSION) \
                          $(full_apt_version ocaml-base $OCAML_VERSION) \
                          $(full_apt_version ocaml $OCAML_VERSION) \
                          $(full_apt_version ocaml-nox $OCAML_VERSION) \
                          $(full_apt_version ocaml-native-compilers $OCAML_VERSION) \
                          $(full_apt_version camlp4 $OCAML_VERSION) \
                          $(full_apt_version camlp4-extra $OCAML_VERSION) \
                          opam time
}

install_on_osx () {
  curl -OL "http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.6.dmg"
  sudo hdiutil attach XQuartz-2.7.6.dmg
  sudo installer -verbose -pkg /Volumes/XQuartz-2.7.6/XQuartz.pkg -target /
  case "$OCAML_VERSION,$OPAM_VERSION" in
  4.01.0,1.1.*) brew install opam ;;
  4.01.0,1.2.*) brew update; brew install opam --HEAD ;;
  4.02.1,1.1.*) brew install opam ;;
  4.02.1,1.2.*) brew update; brew install opam --HEAD ;;
  *) echo Unknown $OCAML_VERSION,$OPAM_VERSION; exit 1 ;;
  esac
}

case $TRAVIS_OS_NAME in
osx) install_on_osx ;;
linux) install_on_linux ;;
esac

echo OCaml version
ocaml -version
echo OPAM versions
opam --version
opam --git-version

export OPAMYES=1

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
  case $OCAML_VERSION,$TRAVIS_OS_NAME in
  4.02.1,osx)
    opam switch 4.02.1
    eval `opam config env`
    ;;
  esac
  echo Current switch is:
  opam switch
  # test for installability
  case "$OPAM_VERSION" in
      1.0.*|1.1.*)
          avail_cmd="opam install $pkg --dry-run | grep -E -v \"The dependency [^ ]+ of package [^ ]+ is not available for your compiler or your OS.\" | grep -v \"Your request cannot be satisfied.\" || true"
          ;;
      *)
          avail_cmd="opam list -s -a $pkg | grep -v \"No packages found.\""
          ;;
  esac
  is_available=$(eval $avail_cmd) # eval for a real pipe
  if [ -z "$is_available" ] ; then
      echo $avail_cmd
      echo Skipping $pkg as not installable
  else
    echo "Begin availability check:"
    echo $avail_cmd
    echo $is_available
    echo "End   availability check."
    case $TRAVIS_OS_NAME in
    linux)
      depext=`opam install $pkg -e ubuntu`
      echo Ubuntu depexts: $depext
      if [ "$depext" != "" ]; then
        sudo apt-get install -qq pkg-config build-essential m4 $depext
      fi
      srcext=`opam install $pkg -e source,linux`
      if [ "$srcext" != "" ]; then
        curl -sL ${srcext} | bash
      fi
      ;;
    osx)
      depext=`opam install $pkg -e osx,homebrew`
      echo Homebrew depexts: $depext
      if [ "$depext" != "" ]; then
        brew install $depext
      fi
      srcext=`opam install $pkg -e osx,source`
      if [ "$srcext" != "" ]; then
        curl -sL ${srcext} | bash
      fi
      ;;
    esac
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
