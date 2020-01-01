#!/bin/bash

GHDL_PATH=/opt/ghdl

sudo apt-get -y install git wget build-essential automake autoconf autoconf-archive \
  flex check llvm-5.0-dev clang-5.0 llvm-dev clang gnat pkg-config zlib1g-dev curl \
  texinfo ruby libmpfr-dev libmpc-dev libgmp-dev

if [ -d "ghdl" ]; then
  rm -rf ghdl
fi

git clone https://github.com/ghdl/ghdl.git

cd ghdl

mkdir build
cd build

../configure --prefix=$GHDL_PATH --with-llvm-config=/usr/bin/llvm-config-5.0

make -j$(nproc)
sudo make install
