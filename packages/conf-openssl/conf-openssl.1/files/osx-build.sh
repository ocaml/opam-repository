#!/bin/sh

if [ -d "$HOME/.nix-profile/lib/pkgconfig/" ]; then
  # Nix on macOS
  res=$(env PKG_CONFIG_PATH=$HOME/.nix-profile/lib/pkgconfig pkg-config openssl)
  if [ $? -eq 0 ]; then
    echo $res
    exit 0
  fi
fi

if [ -d "/usr/local/opt/openssl/" ]; then
  # Homebrew
  res=$(env PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig pkg-config openssl)
  if [ $? -eq 0 ]; then
    echo $res
    exit 0
  fi
fi

# MacPorts
PKG_CONFIG_PATH=/opt/local/lib/pkgconfig pkg-config openssl
