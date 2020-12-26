#include "encoding.h"
#include <stdint.h>

#define CYCLES_PER_SECONDS 50000000
#define UART_BASE_ADDRESS 0x100000
#define MTIMECMP 0x200000
#define MTIME 0x200008
#define HOST_ADDRESS 0x1000

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
  unsigned long long volatile * const host = (unsigned long long*) HOST_ADDRESS;
  unsigned long long offset;
  unsigned long long result;
  unsigned char a;
  unsigned char b;
  unsigned char c;
  int cond = 0;
  for (int i=0; i<size; i++)
  {
    for (int j=0; j<counter; j++)
    {
      offset = i*CACHE_LINE*SET_SIZE + j*CACHE_LINE;
      result = *(port+offset);
      if (result != (i+1)*(j+1))
      {
        a = '0' + result;
        b = '0' + i;
        c = '0' + j;
        putch(a);
        putch(' ');
        putch('=');
        putch(' ');
        putch(b);
        putch(' ');
        putch('*');
        putch(' ');
        putch(c);
        putch('\r');
        putch('\n');
        cond = 1;
      }
    }
  }
  if (cond == 1)
  {
    *(host) = 0xFF;
  }
  else
  {
    *(host) = 0x1;
  }
}

int main()
{
  write(10,10);
  read(10,10);
  while(1)
  {};
}
