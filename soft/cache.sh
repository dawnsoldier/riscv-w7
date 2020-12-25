#!/bin/bash

export RISCV=$1
export MARCH=$2
export MABI=$3
export ITER=$4
export PYTHON=$5
export OFFSET=$6
export BASEDIR=$7

ELF2COE=$BASEDIR/soft/py/elf2coe.py
ELF2DAT=$BASEDIR/soft/py/elf2dat.py
ELF2MIF=$BASEDIR/soft/py/elf2mif.py
ELF2HEX=$BASEDIR/soft/py/elf2hex.py

if [ ! -d "${BASEDIR}/build" ]; then
  mkdir ${BASEDIR}/build
fi

rm -rf ${BASEDIR}/build/cache

mkdir ${BASEDIR}/build/cache

mkdir ${BASEDIR}/build/cache/elf
mkdir ${BASEDIR}/build/cache/dump
mkdir ${BASEDIR}/build/cache/coe
mkdir ${BASEDIR}/build/cache/dat
mkdir ${BASEDIR}/build/cache/mif
mkdir ${BASEDIR}/build/cache/hex

make -f ${BASEDIR}/soft/src/cache/Makefile || exit

shopt -s nullglob
for filename in ${BASEDIR}/build/cache/elf/*.elf; do
  echo $filename
  ${PYTHON} ${ELF2COE} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/cache
  ${PYTHON} ${ELF2DAT} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/cache
  ${PYTHON} ${ELF2MIF} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/cache
  ${PYTHON} ${ELF2HEX} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/cache
done

shopt -s nullglob
for filename in ${BASEDIR}/build/cache/elf/*.dump; do
  mv ${filename} ${BASEDIR}/build/cache/dump/
done
