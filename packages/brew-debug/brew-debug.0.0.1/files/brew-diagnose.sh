#!/bin/sh
env
brew install gmp
brew config | grep 'HOMEBREW_VERSION\|HOMEBREW_PREFIX\|BOOTTLE\|macOS'
stat /usr/local/lib/libgmp.a
exit 1
