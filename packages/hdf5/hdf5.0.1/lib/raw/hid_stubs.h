#define Hid_val(v) *((hid_t*) Data_custom_val(v))
#define Hid_closed(v) *((bool*) ((char*) Data_custom_val(v) + sizeof(hid_t)))
value alloc_hid(hid_t);
size_t hid_array_val(value, hid_t**);
value val_hid_array(size_t, hid_t*);
