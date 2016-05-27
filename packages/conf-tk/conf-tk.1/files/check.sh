pkg-config tk || \
cc -o /dev/null \
  -I/usr/include/tk \
  -I/usr/local/include/tk \
  -I/opt/X11/include \
  compiletest.c
