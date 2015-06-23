full_apt_version () {
  package=$1
  version=$2
  echo -n "${package}="
  apt-cache show $package | sed -n "s/^Version: \(${version}\)/\1/p" | head -1
}

install_on_linux () {
  # Install OCaml and OPAM PPAs
  case "$OCAML_VERSION,$OPAM_VERSION" in
  3.12.1,1.1.1) ppa=avsm/ocaml312+opam11 ;;
  3.12.1,1.2.1) ppa=avsm/ocaml312+opam12 ;;
  4.00.1,1.1.1) ppa=avsm/ocaml40+opam11 ;;
  4.00.1,1.2.1) ppa=avsm/ocaml40+opam12 ;;
  4.01.0,1.1.1) ppa=avsm/ocaml41+opam11 ;;
  4.01.0,1.2.1) ppa=avsm/ocaml41+opam12 ;;
  4.02.1,1.1.1) ppa=avsm/ocaml42+opam11 ;;
  4.02.1,1.2.0) ppa=avsm/ocaml42+opam120 ;;
  4.02.1,1.2.1) ppa=avsm/ocaml42+opam12 ;;
  4.03.0,1.2.1) OCAML_VERSION=4.02.1; OCAML_SWITCH="4.03.0dev+trunk"; ppa=avsm/ocaml42+opam12 ;;
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
  4.02.1,1.2.0) brew update; brew install opam ;;
  4.02.1,1.2.1) brew update; brew install opam --HEAD ;;
  4.03.0,1.2.1) brew update; brew install ocaml --HEAD; brew install opam --HEAD ;;
  *) echo Unknown $OCAML_VERSION,$OPAM_VERSION; exit 1 ;;
  esac
}

case $TRAVIS_OS_NAME in
osx) install_on_osx ;;
linux) install_on_linux ;;
esac
