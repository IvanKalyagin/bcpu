OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  . = 0x0000;
  .text : { *(.text) }
  . = 0x10000;
  .data : { *(.data) }
  .bss : { *(.bss) }
  /DISCARD/ : { *(.riscv.attributes) }
  _end = .;
}
