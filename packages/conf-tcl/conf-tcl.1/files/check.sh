pkg-config tcl || \
cc -o /dev/null \
  -I/usr/include/tcl \
  -I/usr/local/include/tcl \
  -I/usr/local/include/tcl8.6 \
  compiletest.c
