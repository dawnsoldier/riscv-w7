default: all

src_dir = $(BASEDIR)/soft/src
bld_dir = $(BASEDIR)/build/cache/elf
srcs = $(wildcard $(src_dir)/cache/*.S) $(wildcard $(src_dir)/cache/*.c)
objs0 = $(srcs:.c=.o)
objs = $(objs0:.S=.o)

RISCV_GCC ?= $(RISCV)/riscv64-unknown-elf-gcc
RISCV_GCC_OPTS ?= -march=$(MARCH) -mabi=$(MABI) -g -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -fno-inline -ffast-math -fno-common -fno-builtin-printf
RISCV_LINK_OPTS ?= -static -nostartfiles -lm -lgcc -T $(src_dir)/cache/link.ld
RISCV_OBJDUMP ?= $(RISCV)/riscv64-unknown-elf-objdump -S -Mnumeric,no-aliases --disassemble-all --disassemble-zeroes
RISCV_OBJCOPY ?= $(RISCV)/riscv64-unknown-elf-objcopy -O binary
RISCV_INCL ?= -I$(src_dir)/env -I$(src_dir)/cache -I$(src_dir)/common

cache.elf: $(objs)
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) $^ -o $(bld_dir)/$@ $(RISCV_LINK_OPTS)
	cp $(BASEDIR)/soft/src/cache/cache.host $(bld_dir)
	mv $^ $(bld_dir)

%.o: %.c
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) -c $< -o $@

%.o: %.S
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) -c $< -o $@

cache.dump: $(bld_dir)/cache.elf
	$(RISCV_OBJDUMP) $< > $(bld_dir)/$@

cache.bin: $(bld_dir)/cache.elf
	$(RISCV_OBJCOPY) $< $(bld_dir)/$@

# Default

all: cache.elf cache.dump cache.bin
