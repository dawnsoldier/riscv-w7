/*======================================================================*/
/* Baremetal Linker Script                                              */
/*======================================================================*/
/* Taken from riscv-tests
/*----------------------------------------------------------------------*/
/* Setup                                                                */
/*----------------------------------------------------------------------*/

/* The OUTPUT_ARCH command specifies the machine architecture where the
   argument is one of the names used in the BFD library. More
   specifically one of the entires in bfd/cpu-mips.c */

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

/*----------------------------------------------------------------------*/
/* Sections                                                             */
/*----------------------------------------------------------------------*/

SECTIONS
{

  /* text: test code section */
  . = 0;
  .text.init : { *(.text.init) }
  .text : { *(.text) }

  /* data segment */
  . = 0x30000;
  .data : { *(section1*) *(section2*) }


  . = ALIGN(0x300000);
  .tohost : { *(.tohost) }
  .rodata : { *(rodata) }

  /* End of uninitalized data segement */
  _end = .;
}
