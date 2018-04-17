#!/usr/bin/env bash

yum update -y
yum install -y git gcc gcc-c++ gcc-gfortran make kernel-devel

git clone --depth 1 https://github.com/xianyi/OpenBLAS.git --branch v0.2.20
cd OpenBLAS
make && sudo make install
cd ..
rm -rf OpenBLAS
