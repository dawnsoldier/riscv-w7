#!/bin/bash

export RISCV=$1
export MARCH=$2
export MABI=$3
export XLEN=$4
export PYTHON=$5
export OFFSET=$6
export BASEDIR=$7
export OVP=$8

ELF2COE=$BASEDIR/soft/py/elf2coe.py
ELF2DAT=$BASEDIR/soft/py/elf2dat.py
ELF2MIF=$BASEDIR/soft/py/elf2mif.py
ELF2HEX=$BASEDIR/soft/py/elf2hex.py

if [ ! -d "${BASEDIR}/build" ]; then
  mkdir ${BASEDIR}/build
fi

rm -rf ${BASEDIR}/build/ovp
mkdir ${BASEDIR}/build/ovp

mkdir ${BASEDIR}/build/ovp/elf
mkdir ${BASEDIR}/build/ovp/dump
mkdir ${BASEDIR}/build/ovp/coe
mkdir ${BASEDIR}/build/ovp/dat
mkdir ${BASEDIR}/build/ovp/mif
mkdir ${BASEDIR}/build/ovp/hex

if [ -d "${BASEDIR}/soft/src/riscv-ovp" ]; then
  rm -rf ${BASEDIR}/soft/src/riscv-ovp
fi

unzip ${OVP} -d ${BASEDIR}/soft/src/riscv-ovp

cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-env/*.h ${BASEDIR}/soft/src/ovp/env/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-env/p ${BASEDIR}/soft/src/ovp/env/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-target/sail-riscv-c/*.h ${BASEDIR}/soft/src/ovp/target/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv64ic/src/* ${BASEDIR}/soft/src/ovp/rv64ic/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv64i/src/* ${BASEDIR}/soft/src/ovp/rv64i/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv64b/src/* ${BASEDIR}/soft/src/ovp/rv64b/
cp -r ${BASEDIR}/soft/src/riscv-ovp/imperas-riscv-tests/riscv-test-suite/rv64m/src/* ${BASEDIR}/soft/src/ovp/rv64m/

make -f ${BASEDIR}/soft/src/ovp/Makefile || exit

shopt -s nullglob
for filename in ${BASEDIR}/build/ovp/elf/rv64*.dump; do
  echo $filename
  ${PYTHON} ${ELF2COE} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/ovp
  ${PYTHON} ${ELF2DAT} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/ovp
  ${PYTHON} ${ELF2MIF} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/ovp
  ${PYTHON} ${ELF2HEX} ${filename%.dump} 0x0 ${OFFSET} ${BASEDIR}/build/ovp
done

shopt -s nullglob
for filename in ${BASEDIR}/build/ovp/elf/rv64*.dump; do
  mv ${filename} ${BASEDIR}/build/ovp/dump/
done
