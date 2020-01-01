#!/bin/bash

export RISCV=$1
export MARCH=$2
export MABI=$3
export PYTHON=$4
export OFFSET=$5
export BASEDIR=$6

cd $BASEDIR/tools/riscv-torture/
sbt generator/run > /dev/null
cd -

RISCV_GCC=$RISCV/riscv64-unknown-elf-gcc
RISCV_GCC_OPTS="-march=$MARCH -mabi=$MABI -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -ffast-math -fno-common -fno-builtin-printf"
RISCV_LINK_OPTS="-static -nostdlib -nostartfiles -lm -lgcc -T $BASEDIR/tools/riscv-torture/env/p/link.ld"
RISCV_OBJDUMP="/opt/riscv/bin/riscv64-unknown-elf-objdump -Mnumeric,no-aliases --disassemble-all --disassemble-zeroes"
RISCV_OBJCOPY="/opt/riscv/bin/riscv64-unknown-elf-objcopy -O binary"
RISCV_INCL="-I $BASEDIR/soft/src/common -I $BASEDIR/soft/src/env"
RISCV_SRC="$BASEDIR/tools/riscv-torture/output/test.S"

ELF2COE=$BASEDIR/soft/py/elf2coe.py
ELF2DAT=$BASEDIR/soft/py/elf2dat.py
ELF2MIF=$BASEDIR/soft/py/elf2mif.py
ELF2HEX=$BASEDIR/soft/py/elf2hex.py

if [ ! -d "${BASEDIR}/build" ]; then
  mkdir ${BASEDIR}/build
fi

rm -rf ${BASEDIR}/build/verification

mkdir ${BASEDIR}/build/verification

mkdir ${BASEDIR}/build/verification/elf
mkdir ${BASEDIR}/build/verification/dump
mkdir ${BASEDIR}/build/verification/coe
mkdir ${BASEDIR}/build/verification/dat
mkdir ${BASEDIR}/build/verification/mif
mkdir ${BASEDIR}/build/verification/hex

$RISCV_GCC $RISCV_GCC_OPTS $RISCV_LINK_OPTS -o ${BASEDIR}/build/verification/elf/verification.elf $RISCV_SRC $RISCV_INCL
$RISCV_OBJCOPY ${BASEDIR}/build/verification/elf/verification.elf ${BASEDIR}/build/verification/elf/verification.bin
$RISCV_OBJDUMP ${BASEDIR}/build/verification/elf/verification.elf > ${BASEDIR}/build/verification/dump/verification.dump

shopt -s nullglob
for filename in ${BASEDIR}/build/verification/elf/*.elf; do
  echo $filename
  ${PYTHON} ${ELF2COE} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/verification
  ${PYTHON} ${ELF2DAT} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/verification
  ${PYTHON} ${ELF2MIF} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/verification
  ${PYTHON} ${ELF2HEX} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/verification
done

shopt -s nullglob
for filename in ${BASEDIR}/build/verification/elf/*.dump; do
  mv ${filename} ${BASEDIR}/build/verification/dump/
done
