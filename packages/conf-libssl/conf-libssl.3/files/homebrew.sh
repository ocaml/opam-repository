#!/bin/sh -ex

# check the openssl installation
# and symlink the homebrew pkg-config files for openssl to the opam local pkgconfig directory

brew_pkg_config=$(brew --prefix openssl)/lib/pkgconfig

case "$1" in
check)
  if test "$#" != 1; then
    echo "Usage: $0 check"
    exit 1
  fi
  export PKG_CONFIG_PATH=$brew_pkg_config:$PKG_CONFIG_PATH
  pkg-config --print-errors --exists openssl;;
install)
  if test "$#" != 2; then
    echo "Usage: $0 install <libdir>"
    exit 1
  fi
  cd "$brew_pkg_config"
  for file in $(ls *.pc); do
    if test -f "$file"; then
      ln -s "$brew_pkg_config/$file" "$2/pkgconfig/$file"
    fi
  done;;
*)
  echo "Usage: $0 <check|install>"
  exit 1;;
esac
