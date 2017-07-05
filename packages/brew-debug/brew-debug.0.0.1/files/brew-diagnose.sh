#!/bin/sh
echo "--env------------------------------------------------------------------"
env
echo "--brew-config----------------------------------------------------------"
brew config | grep 'HOMEBREW_VERSION\|HOMEBREW_PREFIX\|BOOTTLE\|macOS'
brew list --versions | grep gmp
exit 1
