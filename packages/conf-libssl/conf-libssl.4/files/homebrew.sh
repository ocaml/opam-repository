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
    export PKG_CONFIG_PATH="$brew_pkg_config:$PKG_CONFIG_PATH"
    pkg-config --print-errors --exists openssl
    ;;
  install)
    if test "$#" != 2; then
      echo "Usage: $0 install <libdir>"
      exit 1
    fi
    for fpath in "$brew_pkg_config"/*.pc; do
      test -e "$fpath" || break
      fname=$(basename "$fpath")
      tdir="$2/pkgconfig"
      mkdir -p "$tdir"
      ln -s "$fpath" "$tdir/$fname"
    done
    ;;
  *)
    echo "Usage: $0 <check|install>"
    exit 1
    ;;
esac
