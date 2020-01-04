default: none

GHDL ?= /opt/ghdl/bin/ghdl
RISCV ?= /opt/riscv/bin
MARCH ?= rv64imfdc
MABI ?= lp64d
ITER ?= 1
CSMITH ?= /opt/csmith
CSMITH_INCL ?= $(shell ls -d $(CSMITH)/include/csmith-* | head -n1)
GCC ?= /usr/bin/gcc
PYTHON ?= /usr/bin/python2
BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
OFFSET ?= 0x10000 # Number of dwords in blockram (address range is OFFSET * 8)
TEST ?= dhrystone
CYCLES ?= 10000000
WAVE ?= "" # "wave" for saving dump file

generate_isa:
	soft/isa.sh ${RISCV} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_dhrystone:
	soft/dhrystone.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_coremark:
	soft/coremark.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_csmith:
	soft/csmith.sh ${RISCV} ${MARCH} ${MABI} ${GCC} ${CSMITH} ${CSMITH_INCL} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_verification:
	soft/verification.sh ${RISCV} ${MARCH} ${MABI} ${PYTHON} ${OFFSET} ${BASEDIR}

simulate:
	sim/run.sh ${BASEDIR} ${GHDL} ${TEST} ${CYCLES} ${WAVE}

all: generate_isa generate_dhrystone generate_coremark generate_csmith generate_verification simulate