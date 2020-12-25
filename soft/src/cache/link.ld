OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  . = 0x0;
  .text : { *(.text) }
  . = ALIGN(0x200);
  .data : { *(.data) }
  .bss : { *(.bss) }
  _end = .;
}
