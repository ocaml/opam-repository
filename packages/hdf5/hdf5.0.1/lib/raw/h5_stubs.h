#define Int_opt_val(v, d) Is_block(v) ? Int_val(Field(v, 0)) : d

size_t unsigned_int_array_val(value, unsigned int**);
size_t size_t_array_val(value, size_t**);
value val_size_t_array(size_t, size_t*);
size_t hsize_t_array_val(value, hsize_t**);
size_t hsize_t_array_opt_val(value, hsize_t**);
value val_hsize_t_array(size_t, hsize_t*);
size_t string_array_val(value, char***);
value val_string_array(size_t, const char**);
H5_iter_order_t H5_iter_order_val(value);
H5_iter_order_t H5_iter_order_opt_val(value);
value Val_h5_iter_order(H5_iter_order_t);
int H5_iter_val(value);
value Val_h5_iter(int);
H5_index_t H5_index_val(value);
H5_index_t H5_index_opt_val(value);
value Val_h5_index(H5_index_t);
H5_ih_info_t H5_ih_info_val(value);
value Val_h5_ih_info(H5_ih_info_t);
value Val_htri(htri_t);
value Val_ssize(ssize_t);
struct custom_operations *caml_ba_ops;
