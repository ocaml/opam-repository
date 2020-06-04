#include "zstd.h"
#if ZSTD_VERSION_NUMBER < 10308
# error "zstd it too old (should be at least 1.3.8)"
#endif
int main() { return 0; }
