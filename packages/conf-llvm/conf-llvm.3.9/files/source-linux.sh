#!/bin/sh

sudo add-apt-repository 'deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.9 main'
curl -L http://llvm.org/apt/llvm-snapshot.gpg.key | sudo apt-key add -

sudo apt-get update -qq

sudo apt-get install -qq llvm-3.9-dev
