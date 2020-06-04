#include <unistd.h>
#include <sys/socket.h>

#include <bluetooth/bluetooth.h>
#include <bluetooth/rfcomm.h>
#include <bluetooth/hci.h>
#include <bluetooth/hci_lib.h>

int main(int argc, char **argv)
{
  socket(AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);
  return 0;
}
