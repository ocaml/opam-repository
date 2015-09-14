#include <stdio.h>
#include <sys/time.h>

struct particle { double pressure, lati, longi, temperature; };

#define NREPS 1000
#define LEN 1000

void main()
{
  struct particle a[LEN], *e;
  int i, rep;
  struct timeval t0, t1;
  double pressure, lati, longi, temperature, s = 0;

  for (i = 0; i < LEN; i++)
  {
    e = a + i;
    e->pressure = i;
    e->lati = i;
    e->longi = i;
    e->temperature = 2 * i;
  }

  gettimeofday(&t0, NULL);
  for (rep = 0; rep < NREPS; rep++)
  {
    e = a;
    pressure = 0;
    lati = 0;
    longi = 0;
    temperature = 0;
    for (i = 0; i < LEN; i++)
    {
      pressure    += e->pressure;
      lati        += e->lati;
      longi       += e->longi;
      temperature += e->temperature;
      e++;
    }
    s += pressure + lati + longi + temperature;
  }
  gettimeofday(&t1, NULL);
  printf("%f %f\n",
    ((t1.tv_sec - t0.tv_sec) * 1000000 + (t1.tv_usec - t0.tv_usec))
      * 1000. / (NREPS * LEN), s);
}
