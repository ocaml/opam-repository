#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include "hdf5.h"
#include "hdf5_caml.h"

void hdf5_h5p_free_vlen_mem_manager(value id_v)
{
  H5MM_allocate_t alloc;
  H5MM_free_t free;
  void *alloc_info, *free_info;
  herr_t err;

  err = H5Pget_vlen_mem_manager(Hid_val(id_v), &alloc, &alloc_info, &free, &free_info);
  if (err < 0) return;
  if (alloc != NULL)
    caml_remove_generational_global_root((value*) alloc_info);
  if (free != NULL)
    caml_remove_generational_global_root((value*) free_info);
}

void h5p_finalize(value v)
{
  if (!Hid_closed(v))
  {
    H5Pclose(Hid_val(v));
    hdf5_h5p_free_vlen_mem_manager(v);
    Hid_closed(v) = true;
  }
}

static struct custom_operations h5p_ops = {
  "hdf5.h5p",
  h5p_finalize,
  custom_compare_default,
  custom_compare_ext_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default
};

value alloc_h5p(hid_t id)
{
  value v;
  raise_if_fail(id);
  v = caml_alloc_custom(&h5p_ops, sizeof(hid_t) + sizeof(bool), 0, 1);
  Hid_val(v) = id;
  Hid_closed(v) = false;
  return v;
}

value hdf5_h5p_create(value cls_id_v)
{
  CAMLparam1(cls_id_v);

  hid_t cls_id;

  switch (Int_val(cls_id_v))
  {
    case  0: cls_id = H5P_OBJECT_CREATE; break;
    case  1: cls_id = H5P_FILE_CREATE; break;
    case  2: cls_id = H5P_FILE_ACCESS; break;
    case  3: cls_id = H5P_DATASET_CREATE; break;
    case  4: cls_id = H5P_DATASET_ACCESS; break;
    case  5: cls_id = H5P_DATASET_XFER; break;
    case  6: cls_id = H5P_FILE_MOUNT; break;
    case  7: cls_id = H5P_GROUP_CREATE; break;
    case  8: cls_id = H5P_GROUP_ACCESS; break;
    case  9: cls_id = H5P_DATATYPE_CREATE; break;
    case 10: cls_id = H5P_DATATYPE_ACCESS; break;
    case 11: cls_id = H5P_STRING_CREATE; break;
    case 12: cls_id = H5P_ATTRIBUTE_CREATE; break;
    case 13: cls_id = H5P_OBJECT_COPY; break;
    case 14: cls_id = H5P_LINK_CREATE; break;
    case 15: cls_id = H5P_LINK_ACCESS; break;
    default: caml_failwith("unrecognized cls_id");
  }

  CAMLreturn(alloc_h5p(H5Pcreate(cls_id)));
}

void hdf5_h5p_close(value plist_v)
{
  CAMLparam1(plist_v);
  raise_if_fail(H5Pclose(Hid_val(plist_v)));
  Hid_closed(plist_v) = true;
  CAMLreturn0;
}

void hdf5_h5p_set_userblock(value plist_v, value size_v)
{
  CAMLparam2(plist_v, size_v);
  raise_if_fail(H5Pset_userblock(Hid_val(plist_v), Int_val(size_v)));
  CAMLreturn0;
}

void hdf5_h5p_set_create_intermediate_group(value lcpl_v, value crt_intermed_group_v)
{
  CAMLparam2(lcpl_v, crt_intermed_group_v);
  raise_if_fail(H5Pset_create_intermediate_group(Hid_val(lcpl_v),
    Bool_val(crt_intermed_group_v)));
  CAMLreturn0;
}

value hdf5_h5p_get_create_intermediate_group(value lcpl_v)
{
  CAMLparam1(lcpl_v);
  unsigned crt_intermed_group;
  raise_if_fail(H5Pget_create_intermediate_group(Hid_val(lcpl_v), &crt_intermed_group));
  CAMLreturn(Val_int(crt_intermed_group));
}

value hdf5_h5p_get_layout(value plist_v)
{
  CAMLparam1(plist_v);
  CAMLreturn(Val_h5d_layout(H5Pget_layout(Hid_val(plist_v))));
}

void hdf5_h5p_set_chunk(value plist_v, value dim_v)
{
  CAMLparam2(plist_v, dim_v);
  int ndims;
  hsize_t *dim;
  herr_t err;

  ndims = hsize_t_array_val(dim_v, &dim);
  if (dim == NULL)
    caml_raise_out_of_memory();
  err = H5Pset_chunk(Hid_val(plist_v), ndims, dim);
  free(dim);
  raise_if_fail(err);

  CAMLreturn0;
}

value hdf5_h5p_get_chunk(value plist_v)
{
  CAMLparam1(plist_v);
  int max_ndims;
  hsize_t *dims;
  CAMLlocal1(v);

  max_ndims = H5Pget_chunk(Hid_val(plist_v), 0, NULL);
  dims = calloc(max_ndims, sizeof(hsize_t));
  if (dims == NULL)
    caml_raise_out_of_memory();
  H5Pget_chunk(Hid_val(plist_v), max_ndims, dims);
  v = val_hsize_t_array(max_ndims, dims);
  free(dims);
  CAMLreturn(v);
}

void hdf5_h5p_set_deflate(value plist_id_v, value level_v)
{
  CAMLparam2(plist_id_v, level_v);
  raise_if_fail(H5Pset_deflate(Hid_val(plist_id_v), Int_val(level_v)));
  CAMLreturn0;
}

void hdf5_h5p_set_filter(value plist_v, value filter_v, value flags_v, value cd_v)
{
  CAMLparam4(plist_v, filter_v, flags_v, cd_v);
  size_t cd_nelmts;
  unsigned int *cd_values;
  herr_t err;
  cd_nelmts = unsigned_int_array_val(cd_v, &cd_values);
  if (cd_values == NULL)
    fail();
  err = H5Pset_filter(Hid_val(plist_v), H5Z_filter_val(filter_v), flag_val(flags_v),
    cd_nelmts, cd_values);
  free(cd_values);
  raise_if_fail(err);
  CAMLreturn0;
}

void hdf5_h5p_set_fletcher32(value plist_v)
{
  CAMLparam1(plist_v);
  raise_if_fail(H5Pset_fletcher32(Hid_val(plist_v)));
  CAMLreturn0;
}

void hdf5_h5p_set_nbit(value plist_v)
{
  CAMLparam1(plist_v);
  raise_if_fail(H5Pset_nbit(Hid_val(plist_v)));
  CAMLreturn0;
}

void hdf5_h5p_set_shuffle(value plist_v)
{
  CAMLparam1(plist_v);
  raise_if_fail(H5Pset_shuffle(Hid_val(plist_v)));
  CAMLreturn0;
}

void *hdf5_h5p_alloc(size_t size, void *alloc_info)
{
  return (void*) caml_callback_exn(*((value*) alloc_info), Val_int(size));
}

void hdf5_h5p_free(void *mem, void *free_info)
{
  caml_callback_exn(*((value*) free_info), *((value*) mem));
}

void hdf5_h5p_set_vlen_mem_manager(value plist_id_v, value alloc_v, value free_v)
{
  CAMLparam3(plist_id_v, alloc_v, free_v);
  value *alloc_info, *free_info;
  herr_t err;

  hdf5_h5p_free_vlen_mem_manager(plist_id_v);

  alloc_info = malloc(sizeof(value));
  if (alloc_info == NULL)
    caml_raise_out_of_memory();
  free_info = malloc(sizeof(value));
  if (free_info == NULL)
  {
    free(alloc_info);
    caml_raise_out_of_memory();
  }
  *alloc_info = alloc_v;
  caml_register_generational_global_root(alloc_info);
  *free_info = free_v;
  caml_register_generational_global_root(free_info);
  err = H5Pset_vlen_mem_manager(Hid_val(plist_id_v), hdf5_h5p_alloc, (void*) alloc_info,
    hdf5_h5p_free, (void*) free_info);
  if (err < 0)
  {
    free(alloc_info);
    free(free_info);
    fail();
  }
  CAMLreturn0;
}

value hdf5_h5p_get_vlen_mem_manager(value plist_id_v)
{
  CAMLparam1(plist_id_v);
  H5MM_allocate_t alloc;
  H5MM_free_t free;
  void *alloc_info, *free_info;
  CAMLlocal1(ret);
  raise_if_fail(H5Pget_vlen_mem_manager(Hid_val(plist_id_v), &alloc, &alloc_info, &free,
    &free_info));
  ret = caml_alloc_tuple(2);
  Store_field(ret, 0, (value) alloc_info);
  Store_field(ret, 1, (value) free_info);
  CAMLreturn(ret);
}
