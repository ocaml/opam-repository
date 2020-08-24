pkg-config tk || \
cc -o /dev/null \
  -I/usr/include/tk \
  -I/usr/local/include/tk \
  -I/usr/local/include/tcl8.6 \
  -I/usr/local/include/tk8.6 \
  -I/usr/local/include \
  -I/opt/X11/include \
  compiletest.c
