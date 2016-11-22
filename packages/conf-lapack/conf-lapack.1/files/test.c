extern double dlamch_(char *CMACH);

int main(int argc, char **argv)
{
  char CMACH = 'E';
	double res = dlamch_(&CMACH);
  return 0;
}
