pkg-config tk || \
cc -o /dev/null \
  -I/usr/include/tk \
  -I/usr/local/include/tk \
  compiletest.c
