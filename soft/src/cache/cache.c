#include "encoding.h"
#include <stdint.h>

#define CYCLES_PER_SECONDS 50000000
#define UART_BASE_ADDRESS 0x100000
#define MTIMECMP 0x200000
#define MTIME 0x200008

#define CACHE_LINE 4
#define SET_SIZE 64
#define STACK_ADDRESS 0x10000

void putch(char ch)
{
  *((volatile char*)UART_BASE_ADDRESS) = ch;
}

void write(long long counter,long long size)
{
  unsigned long long volatile * const port = (unsigned long long*) STACK_ADDRESS;
  unsigned long long offset;
  for (int i=0; i<size; i++)
  {
    for (int j=0; j<counter; j++)
    {
      offset = i*CACHE_LINE*SET_SIZE + j*CACHE_LINE;
      *(port+offset) = (i+1)*(j+1);
    }
  }
}

void read(long long counter,long long size)
{
  unsigned long long volatile * const port = (unsigned long long*) STACK_ADDRESS;
  unsigned long long offset;
  unsigned long long result;
  for (int i=0; i<size; i++)
  {
    for (int j=0; j<counter; j++)
    {
      offset = i*CACHE_LINE*SET_SIZE + j*CACHE_LINE;
      result = *(port+offset);
      if (result != (i+1)*(j+1))
      {
        putch('F');
        putch('A');
        putch('L');
        putch('S');
        putch('E');
        putch('\r');
        putch('\n');
        while(1)
        {};
      }
    }
  }
  putch('T');
  putch('R');
  putch('U');
  putch('E');
  putch('\r');
  putch('\n');
}

int main()
{
  write(10,10);
  read(10,10);
  while(1)
  {};
}
