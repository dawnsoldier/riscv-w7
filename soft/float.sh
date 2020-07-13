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

rm -rf ${BASEDIR}/build/float

mkdir ${BASEDIR}/build/float

mkdir ${BASEDIR}/build/float/elf
mkdir ${BASEDIR}/build/float/dump
mkdir ${BASEDIR}/build/float/coe
mkdir ${BASEDIR}/build/float/dat
mkdir ${BASEDIR}/build/float/mif
mkdir ${BASEDIR}/build/float/hex

make -f ${BASEDIR}/soft/src/float/Makefile || exit

shopt -s nullglob
for filename in ${BASEDIR}/build/float/elf/*.elf; do
  echo $filename
  ${PYTHON} ${ELF2COE} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/float
  ${PYTHON} ${ELF2DAT} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/float
  ${PYTHON} ${ELF2MIF} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/float
  ${PYTHON} ${ELF2HEX} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/float
done

shopt -s nullglob
for filename in ${BASEDIR}/build/float/elf/*.dump; do
  mv ${filename} ${BASEDIR}/build/float/dump/
done
