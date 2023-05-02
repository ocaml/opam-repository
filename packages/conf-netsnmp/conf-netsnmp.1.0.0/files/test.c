#include <net-snmp/net-snmp-config.h>
#include <net-snmp/mib_api.h>

#ifndef NET_SNMP_MIB_API_H
#error "No NetSNMP header"
#endif

void test(void)
{
  netsnmp_init_mib();
}
