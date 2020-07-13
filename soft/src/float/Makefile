default: all

src_dir = $(BASEDIR)/soft/src
bld_dir = $(BASEDIR)/build/float/elf
obj = $(wildcard $(src_dir)/common/*.S) $(wildcard $(src_dir)/common/*.c) $(wildcard $(src_dir)/float/*.c)

RISCV_GCC ?= $(RISCV)/riscv64-unknown-elf-gcc
RISCV_GCC_OPTS ?= -march=$(MARCH) -mabi=$(MABI) -g -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O3 -ffast-math -fno-common -fno-builtin-printf -fno-builtin
RISCV_LINK_OPTS ?= -static -nostdlib -nostartfiles -lm -lgcc -T $(src_dir)/common/test.ld
RISCV_OBJDUMP ?= $(RISCV)/riscv64-unknown-elf-objdump -S -Mnumeric,no-aliases --disassemble-all --disassemble-zeroes
RISCV_OBJCOPY ?= $(RISCV)/riscv64-unknown-elf-objcopy -O binary
RISCV_INCL ?= -I$(src_dir)/env -I$(src_dir)/float -I$(src_dir)/common

float.elf: $(obj)
	echo $(obj)
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) -DNUMBER_OF_RUNS=$(ITER) -o $(bld_dir)/$@ $(obj) $(RISCV_LINK_OPTS)

%.o: %.c
	echo $<
	$(RISCV_GCC) -c $< -o $@

%.o: %.S
	$(RISCV_GCC) -c $< -o $@

float.dump: $(bld_dir)/float.elf
	$(RISCV_OBJDUMP) $< > $(bld_dir)/$@

float.bin: $(bld_dir)/float.elf
	$(RISCV_OBJCOPY) $< $(bld_dir)/$@

# Default

all: float.elf float.dump float.bin
