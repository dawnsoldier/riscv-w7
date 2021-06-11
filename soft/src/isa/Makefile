default: all

src_dir = $(BASEDIR)/soft/src/isa
bld_dir = $(BASEDIR)/build/isa/elf

include $(src_dir)/rv64ui/Makefrag
include $(src_dir)/rv64uc/Makefrag
include $(src_dir)/rv64um/Makefrag
include $(src_dir)/rv64uf/Makefrag
include $(src_dir)/rv64ud/Makefrag
include $(src_dir)/rv64mi/Makefrag

RISCV_GCC ?= $(RISCV)/riscv64-unknown-elf-gcc
RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_INCL ?= -I $(src_dir)/../env -I $(src_dir)/../common -I $(src_dir)/macros/scalar
RISCV_LINK_OPTS ?= -T $(src_dir)/../env/link.ld
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

$(eval $(call compile_template,rv64ui,$(src_dir),$(bld_dir),-march=rv64i -mabi=lp64 -DXLEN=64))
$(eval $(call compile_template,rv64uc,$(src_dir),$(bld_dir),-march=rv64ic -mabi=lp64 -DXLEN=64))
$(eval $(call compile_template,rv64um,$(src_dir),$(bld_dir),-march=rv64im -mabi=lp64 -DXLEN=64))
$(eval $(call compile_template,rv64uf,$(src_dir),$(bld_dir),-march=rv64if -mabi=lp64 -DXLEN=64))
$(eval $(call compile_template,rv64ud,$(src_dir),$(bld_dir),-march=rv64id -mabi=lp64 -DXLEN=64))
$(eval $(call compile_template,rv64mi,$(src_dir),$(bld_dir),-march=rv64imfd -mabi=lp64 -DXLEN=64))

all: $(tests)

clean:
	rm -rf $(tests)
