extern double cblas_dnrm2(int N, double *X, int INCX);

int main(int argc, char **argv)
{
  int N = 3;
  double X[] = { 1, 2, 3 };
  int INCX = 1;
	double res = cblas_dnrm2(N, X, INCX);
  return 0;
}
