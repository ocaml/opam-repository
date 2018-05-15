#!/bin/sh

PREFIX=$1

if [ -d "/usr/local/opt/openssl/" ]; then
  # Homebrew
  ./configure --prefix "${PREFIX}" CPPFLAGS="-I/usr/local/opt/openssl/include" LDFLAGS="-L/usr/local/opt/openssl/lib"
else
  # MacPorts
  ./configure --prefix "${PREFIX}" CPPFLAGS="-I/opt/local/include" LDFLAGS="-L/opt/local/lib"
fi
