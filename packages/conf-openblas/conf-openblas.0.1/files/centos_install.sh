#!/usr/bin/env bash

yes | yum update
yes | yum install git
yes | yum install gcc gcc-c++ gcc-gfortran make kernel-devel

git clone https://github.com/xianyi/OpenBLAS.git
cd OpenBLAS
make && make install
cd ..
rm -rf OpenBLAS
