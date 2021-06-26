default: none

GHDL ?= /opt/ghdl/bin/ghdl
RISCV ?= /opt/riscv/bin
XLEN ?= 64
MARCH ?= rv64imfdc
MABI ?= lp64d
ITER ?= 1
CSMITH ?= /opt/csmith
CSMITH_INCL ?= $(shell ls -d $(CSMITH)/include/csmith-* | head -n1)
GCC ?= /usr/bin/gcc
PYTHON ?= /usr/bin/python2
BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
OVP ?= riscv-ovpsim-plus-bitmanip-tests.zip
OFFSET ?= 0x40000 # Number of dwords in blockram (address range is OFFSET * 8)
TEST ?= dhrystone
AAPG ?= aapg
CONFIG ?= integer
CYCLES ?= 1000000000
WAVE ?= "" # "wave" for saving dump file

generate_isa:
	soft/isa.sh ${RISCV} ${MARCH} ${MABI} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_compliance:
	soft/compliance.sh ${RISCV} ${MARCH} ${MABI} ${XLEN} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_ovp:
	soft/ovp.sh ${RISCV} ${MARCH} ${MABI} ${XLEN} ${PYTHON} ${OFFSET} ${BASEDIR} ${OVP}

generate_dhrystone:
	soft/dhrystone.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_coremark:
	soft/coremark.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_csmith:
	soft/csmith.sh ${RISCV} ${MARCH} ${MABI} ${GCC} ${CSMITH} ${CSMITH_INCL} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_torture:
	soft/torture.sh ${RISCV} ${MARCH} ${MABI} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_uart:
	soft/uart.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_timer:
	soft/timer.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_float:
	soft/float.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_cache:
	soft/cache.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_aapg:
	soft/aapg.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR} ${AAPG} ${CONFIG}

simulate:
	sim/run.sh ${BASEDIR} ${GHDL} ${TEST} ${CYCLES} ${WAVE}

all: generate_isa generate_dhrystone generate_coremark generate_csmith generate_torture simulate
