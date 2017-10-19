#!/bin/sh

if [ -d "/usr/local/opt/openssl/" ]; then
  # Homebrew
  PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig pkg-config openssl
else
  # MacPorts
  PKG_CONFIG_PATH=/opt/local/lib/pkgconfig pkg-config openssl
fi
