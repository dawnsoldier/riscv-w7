#include "encoding.h"
#include <stdint.h>
#include <math.h>
#include <stdio.h>

int main()
{
  float a = 3.0;
  float b = 2.0;
  float c = 4.0;

  printf("%f / %f = %f \r\n",a,b,a/b);
  printf("%f * %f = %f \r\n",a,b,a*b);
  printf("%f + %f = %f \r\n",a,b,a+b);
  printf("%f - %f = %f \r\n",a,b,a-b);
  printf("%f * %f + %f = %f \r\n",a,b,fma(a,b,c));

  if (a/b == 1.5)
  {
    printf("FDIV SUCCESS!\r\n");
  }
  else
  {
    printf("FDIV FAIL!\r\n");
  }

  if (a*b == 6.0)
  {
    printf("FMUL SUCCESS!\r\n");
  }
  else
  {
    printf("FMUL FAIL!\r\n");
  }

  if (a+b == 5.0)
  {
    printf("FADD SUCCESS!\r\n");
  }
  else
  {
    printf("FADD FAIL!\r\n");
  }

  if (a-b == 1.0)
  {
    printf("FSUB SUCCESS!\r\n");
  }
  else
  {
    printf("FSUB FAIL!\r\n");
  }

  if (fma(a,b,c) == 10.0)
  {
    printf("FMA SUCCESS!\r\n");
  }
  else
  {
    printf("FMA FAIL!\r\n");
  }

  return 0;
}
