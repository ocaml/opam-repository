#define H5P_opt_val(v) Is_block(v) ? Hid_val(Field(v, 0)) : H5P_DEFAULT
value alloc_h5p(hid_t id);
