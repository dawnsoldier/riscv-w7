default: all

src_dir = $(BASEDIR)/soft/src/ovp
bld_dir = $(BASEDIR)/build/ovp/elf

include $(src_dir)/rv64i/Makefrag
include $(src_dir)/rv64ic/Makefrag
include $(src_dir)/rv64b/Makefrag
include $(src_dir)/rv64m/Makefrag

RISCV_GCC ?= $(RISCV)/riscv64-unknown-elf-gcc
RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_INCL ?= -I $(src_dir)/env -I $(src_dir)/env/p -I $(src_dir)/target
RISCV_LINK_OPTS ?= -T $(src_dir)/env/link.ld
RISCV_OBJDUMP ?= $(RISCV)/riscv64-unknown-elf-objdump -Mnumeric,no-aliases --disassemble --disassemble-zeroes
RISCV_OBJCOPY ?= $(RISCV)/riscv64-unknown-elf-objcopy -O binary
RISCV_NM ?= $(RISCV)/riscv64-unknown-elf-nm -A

vpath %.S $(src_dir)

define compile_template

$$($(1)_tests): $(1)-%: $(1)/%.S
	$$(RISCV_GCC) $$(RISCV_GCC_OPTS) $(4) $$(RISCV_INCL) $$(RISCV_LINK_OPTS) $$< -o $(3)/$$@.elf
	$$(RISCV_NM) $(3)/$$@.elf | grep -sw 'tohost' | sed -e 's/.*:\(.*\) D.*/\1/' > $(3)/$$@.host
	$$(RISCV_OBJDUMP) $(3)/$$@.elf > $(3)/$$@.dump
	$$(RISCV_OBJCOPY) $(3)/$$@.elf $(3)/$$@.bin
tests += $$($(1)_tests)

endef

$(eval $(call compile_template,rv64i,$(src_dir),$(bld_dir),-march=rv64i -mabi=lp64 -DXLEN=64))
$(eval $(call compile_template,rv64ic,$(src_dir),$(bld_dir),-march=rv64ic -mabi=lp64 -DXLEN=64))
$(eval $(call compile_template,rv64b,$(src_dir),$(bld_dir),-march=rv64i_zba_zbb_zbc -mabi=lp64 -DXLEN=64))
$(eval $(call compile_template,rv64m,$(src_dir),$(bld_dir),-march=rv64im -mabi=lp64 -DXLEN=64))

all: $(tests)

clean:
	rm -rf $(tests)
