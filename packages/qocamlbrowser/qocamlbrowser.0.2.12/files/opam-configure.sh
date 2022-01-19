#!/bin/sh
set -x

MAKE=make
OS=unknown

if [ "$#" -ge 2 ]; then
  MAKE=$1
  OS=$2
else
  echo "Usage: $0 make OS [OS-family] [OS-distribution]" >&2
  exit 1
fi

if [ "$OS" = "macos"]; then
  export PATH=/usr/lib64/qt5/bin:/usr/lib/qt5/bin:$PATH
  ./configure  || exit 1
  $MAKE  || exit 1
else
  # a few GNU/Linux put executables there
  export PATH=/usr/local/opt/qt/bin:$PATH
  ./configure || exit 1
  $MAKE || exit 1
fi

exit 0
