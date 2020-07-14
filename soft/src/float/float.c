#include "encoding.h"
#include <stdint.h>
#include <math.h>
#include <stdio.h>

int main()
{
  float a = 45.01233;
  float b = 62.84832;
  float c = 95.23156;

  printf("%f / %f = %f \r\n",a,b,a/b);
  printf("%f * %f = %f \r\n",a,b,a*b);
  printf("%f + %f = %f \r\n",a,b,a+b);
  printf("%f - %f = %f \r\n",a,b,a-b);
  printf("%f * %f + %f = %f \r\n",a,b,fma(a,b,c));

  return 0;
}
