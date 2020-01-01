#!/bin/bash

export RISCV=$1
export PYTHON=$2
export OFFSET=$3
export BASEDIR=$4

ELF2COE=$BASEDIR/soft/py/elf2coe.py
ELF2DAT=$BASEDIR/soft/py/elf2dat.py
ELF2MIF=$BASEDIR/soft/py/elf2mif.py
ELF2HEX=$BASEDIR/soft/py/elf2hex.py

if [ ! -d "${BASEDIR}/build" ]; then
  mkdir ${BASEDIR}/build
fi

rm -rf ${BASEDIR}/build/isa
mkdir ${BASEDIR}/build/isa

mkdir ${BASEDIR}/build/isa/elf
mkdir ${BASEDIR}/build/isa/dump
mkdir ${BASEDIR}/build/isa/coe
mkdir ${BASEDIR}/build/isa/dat
mkdir ${BASEDIR}/build/isa/mif
mkdir ${BASEDIR}/build/isa/hex

make -f ${BASEDIR}/soft/src/isa/Makefile || exit

shopt -s nullglob
for filename in ${BASEDIR}/build/isa/elf/rv64*.dump; do
  echo $filename
  ${PYTHON} ${ELF2COE} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/isa
  ${PYTHON} ${ELF2DAT} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/isa
  ${PYTHON} ${ELF2MIF} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/isa
  ${PYTHON} ${ELF2HEX} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/isa
done

shopt -s nullglob
for filename in ${BASEDIR}/build/isa/elf/rv64*.dump; do
  mv ${filename} ${BASEDIR}/build/isa/dump/
done
