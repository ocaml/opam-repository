#include <caml/alloc.h>
#include <caml/bigarray.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include "hdf5.h"
#include "hdf5_hl.h"
#include "hdf5_caml.h"

void hdf5_h5lt_make_dataset(value loc_id_v, value dset_name_v, value type_id_v,
  value buffer_v)
{
  CAMLparam4(loc_id_v, dset_name_v, type_id_v, buffer_v);
  struct caml_ba_array *buffer = Caml_ba_array_val(buffer_v);
  raise_if_fail(H5LTmake_dataset(Hid_val(loc_id_v), String_val(dset_name_v),
    buffer->num_dims, (const hsize_t*) buffer->dim, Hid_val(type_id_v), buffer->data));
  CAMLreturn0;
}

value hdf5_h5lt_get_dataset_info(value loc_id_v, value dset_name_v)
{
  CAMLparam2(loc_id_v, dset_name_v);
  CAMLlocal1(info);
  hid_t loc_id = Hid_val(loc_id_v);
  const char *dset_name = String_val(dset_name_v);
  int rank;
  hsize_t *dims;
  H5T_class_t class_id;
  size_t type_size;
  herr_t err;
  
  raise_if_fail(H5LTget_dataset_ndims(loc_id, dset_name, &rank));
  dims = calloc(rank, sizeof(hsize_t));
  if (dims == NULL)
    caml_raise_out_of_memory();
  err = H5LTget_dataset_info(loc_id, dset_name, dims, &class_id, &type_size);
  if (err < 0)
  {
    free(dims);
    fail();
  }
  info = caml_alloc_tuple(3);
  Store_field(info, 0, val_hsize_t_array(rank, dims));
  Store_field(info, 1, Val_h5t_class(class_id));
  Store_field(info, 2, Val_int(type_size));
  CAMLreturn(info);
}

#define TYPE_FUNCTIONS(type)                                                             \
void hdf5_h5lt_make_dataset_ ## type(value loc_id_v, value dset_name_v, value buffer_v)  \
{                                                                                        \
  CAMLparam3(loc_id_v, dset_name_v, buffer_v);                                           \
  struct caml_ba_array *buffer = Caml_ba_array_val(buffer_v);                            \
  raise_if_fail(H5LTmake_dataset_ ## type(Hid_val(loc_id_v), String_val(dset_name_v),    \
    buffer->num_dims, (const hsize_t*) buffer->dim, buffer->data));                      \
  CAMLreturn0;                                                                           \
}                                                                                        \
                                                                                         \
void hdf5_h5lt_read_dataset_ ## type(value loc_id_v, value dset_name_v,                  \
  value buffer_v)                                                                        \
{                                                                                        \
  CAMLparam3(loc_id_v, dset_name_v, buffer_v);                                           \
  raise_if_fail(H5LTread_dataset_ ## type(Hid_val(loc_id_v), String_val(dset_name_v),    \
    Caml_ba_data_val(buffer_v)));                                                        \
  CAMLreturn0;                                                                           \
}                                                                                        \
                                                                                         \
void hdf5_h5lt_set_attribute_ ## type(value loc_id_v, value obj_name_v,                  \
  value attr_name_v, value buffer_v)                                                     \
{                                                                                        \
  CAMLparam4(loc_id_v, obj_name_v, attr_name_v, buffer_v);                               \
  raise_if_fail(H5LTset_attribute_ ## type(Hid_val(loc_id_v), String_val(obj_name_v),    \
    String_val(attr_name_v), Caml_ba_data_val(buffer_v),                                 \
    Caml_ba_array_val(buffer_v)->dim[0]));                                               \
  CAMLreturn0;                                                                           \
}                                                                                        \
                                                                                         \
void hdf5_h5lt_get_attribute_ ## type(value loc_id_v, value obj_name_v,                  \
  value attr_name_v, value data_v)                                                       \
{                                                                                        \
  CAMLparam4(loc_id_v, obj_name_v, attr_name_v, data_v);                                 \
  raise_if_fail(H5LTget_attribute_ ## type(Hid_val(loc_id_v), String_val(obj_name_v),    \
    String_val(attr_name_v), Caml_ba_data_val(data_v)));                                 \
  CAMLreturn0;                                                                           \
}

TYPE_FUNCTIONS(char)
TYPE_FUNCTIONS(short)
TYPE_FUNCTIONS(int)
TYPE_FUNCTIONS(long)
TYPE_FUNCTIONS(float)
TYPE_FUNCTIONS(double)
