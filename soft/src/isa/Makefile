default: all

src_dir = $(BASEDIR)/soft/src/isa
bld_dir = $(BASEDIR)/build/isa/elf

include $(src_dir)/rv64ui/Makefrag
include $(src_dir)/rv64uc/Makefrag
include $(src_dir)/rv64um/Makefrag
include $(src_dir)/rv64uf/Makefrag
include $(src_dir)/rv64ud/Makefrag
include $(src_dir)/rv64mi/Makefrag

RISCV_GCC ?= /opt/riscv/bin/riscv64-unknown-elf-gcc
RISCV_GCC_OPTS ?= -march=$(MARCH) -mabi=$(MABI) -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_INCL ?= -I $(src_dir)/../env -I $(src_dir)/../common -I $(src_dir)/macros/scalar
RISCV_LINK_OPTS ?= -T $(src_dir)/../env/link.ld
RISCV_OBJDUMP ?= /opt/riscv/bin/riscv64-unknown-elf-objdump -Mnumeric,no-aliases --disassemble-all --disassemble-zeroes
RISCV_OBJCOPY ?= /opt/riscv/bin/riscv64-unknown-elf-objcopy -O binary

vpath %.S $(src_dir)

define compile_template

$$($(1)_tests): $(1)-%: $(1)/%.S
	$$(RISCV_GCC) $$(RISCV_GCC_OPTS) $$(RISCV_INCL) $$(RISCV_LINK_OPTS) $$< -o $(3)/$$@.elf
	$$(RISCV_OBJDUMP) $(3)/$$@.elf > $(3)/$$@.dump
	$$(RISCV_OBJCOPY) $(3)/$$@.elf $(3)/$$@.bin
tests += $$($(1)_tests)

endef

$(eval $(call compile_template,rv64ui,$(src_dir),$(bld_dir)))
$(eval $(call compile_template,rv64uc,$(src_dir),$(bld_dir)))
$(eval $(call compile_template,rv64um,$(src_dir),$(bld_dir)))
$(eval $(call compile_template,rv64uf,$(src_dir),$(bld_dir)))
$(eval $(call compile_template,rv64ud,$(src_dir),$(bld_dir)))
$(eval $(call compile_template,rv64mi,$(src_dir),$(bld_dir)))

all: $(tests)

clean:
	rm -rf $(tests)
