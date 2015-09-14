#include <stdbool.h>
#define H5S_opt_val(v) Is_block(v) ? Hid_val(Field(v, 0)) : -1
value alloc_h5s(hid_t id);
