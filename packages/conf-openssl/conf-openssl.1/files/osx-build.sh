#!/bin/sh

if [ -d "$HOME/.nix-profile/lib/pkgconfig/" ]; then
  # Nix on macOS
  PKG_CONFIG_PATH=$HOME/.nix-profile/lib/pkgconfig pkg-config openssl
elif [ -d "/usr/local/opt/openssl/" ]; then
  # Homebrew
  PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig pkg-config openssl
else
  # MacPorts
  PKG_CONFIG_PATH=/opt/local/lib/pkgconfig pkg-config openssl
fi
