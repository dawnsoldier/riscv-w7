default: all

src_dir = $(BASEDIR)/soft/src
bld_dir = $(BASEDIR)/build/csmith/elf
obj = $(wildcard $(src_dir)/common/*.S) $(wildcard $(src_dir)/common/*.c) $(wildcard $(src_dir)/csmith/*.c)
csmith_incl = $(shell ls -d $(CSMITH)/include/csmith-* | head -n1)

RISCV_GCC ?= $(RISCV)/riscv64-unknown-elf-gcc
RISCV_GCC_OPTS ?= -march=$(MARCH) -mabi=$(MABI) -g -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -ffast-math -fno-common -fno-builtin-printf
RISCV_LINK_OPTS ?= -static -nostdlib -nostartfiles -lm -lgcc -T $(src_dir)/common/test.ld
RISCV_OBJDUMP ?= $(RISCV)/riscv64-unknown-elf-objdump -S -Mnumeric,no-aliases --disassemble-all --disassemble-zeroes
RISCV_OBJCOPY ?= $(RISCV)/riscv64-unknown-elf-objcopy -O binary
RISCV_INCL ?= -I$(src_dir)/env -I$(csmith_incl) -I$(src_dir)/common

csmith.ref:
	${GCC} -I$(csmith_incl) -o $(src_dir)/csmith/csmith.o $(src_dir)/csmith/csmith.c

csmith.elf: $(obj)
	echo $(obj)
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) -o $(bld_dir)/$@ $(obj) $(RISCV_LINK_OPTS)

%.o: %.c
	echo $<
	$(RISCV_GCC) -c $< -o $@

%.o: %.S
	$(RISCV_GCC) -c $< -o $@

csmith.dump: $(bld_dir)/csmith.elf
	$(RISCV_OBJDUMP) $< > $(bld_dir)/$@

csmith.bin: $(bld_dir)/csmith.elf
	$(RISCV_OBJCOPY) $< $(bld_dir)/$@

# Default

all: csmith.elf csmith.dump csmith.bin csmith.ref
