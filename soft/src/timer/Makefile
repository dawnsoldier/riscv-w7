default: all

src_dir = $(BASEDIR)/soft/src
bld_dir = $(BASEDIR)/build/timer/elf
obj = $(wildcard $(src_dir)/timer/*.S) $(wildcard $(src_dir)/timer/*.c)

RISCV_GCC ?= $(RISCV)/riscv64-unknown-elf-gcc
RISCV_GCC_OPTS ?= -march=$(MARCH) -mabi=$(MABI) -g -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -fno-inline -ffast-math -fno-common -fno-builtin-printf
RISCV_LINK_OPTS ?= -static -nostdlib -nostartfiles -lm -lgcc -T $(src_dir)/timer/link.ld
RISCV_OBJDUMP ?= $(RISCV)/riscv64-unknown-elf-objdump -S -Mnumeric,no-aliases --disassemble-all --disassemble-zeroes
RISCV_OBJCOPY ?= $(RISCV)/riscv64-unknown-elf-objcopy -O binary
RISCV_INCL ?= -I$(src_dir)/env -I$(src_dir)/timer -I$(src_dir)/common

timer.elf: $(obj)
	echo $(obj)
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) -DNUMBER_OF_RUNS=$(ITER) -o $(bld_dir)/$@ $(obj) $(RISCV_LINK_OPTS)

%.o: %.c
	echo $<
	$(RISCV_GCC) -c $< -o $@

%.o: %.S
	$(RISCV_GCC) -c $< -o $@

timer.dump: $(bld_dir)/timer.elf
	$(RISCV_OBJDUMP) $< > $(bld_dir)/$@

timer.bin: $(bld_dir)/timer.elf
	$(RISCV_OBJCOPY) $< $(bld_dir)/$@

# Default

all: timer.elf timer.dump timer.bin
