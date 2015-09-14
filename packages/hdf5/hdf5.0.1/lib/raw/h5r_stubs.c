#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include "hdf5.h"
#include "hdf5_caml.h"

static struct custom_operations h5r_ops = {
  "hdf5.h5r",
  custom_finalize_default,
  custom_compare_default,
  custom_compare_ext_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default
};

value alloc_h5r(hid_t id)
{
  value v;
  raise_if_fail(id);
  v = caml_alloc_custom(&h5r_ops, sizeof(hid_t), 0, 1);
  Hid_val(v) = id;
  return v;
}

H5R_type_t H5R_type_val(value type)
{
  switch (Int_val(type))
  {
    case 0: return H5R_OBJECT;
    case 1: return H5R_DATASET_REGION;
    default: caml_failwith("unrecognized H5R_type_t");
  }
}

value Val_h5r_type(H5R_type_t type)
{
  switch (type)
  {
    case H5R_BADTYPE:        fail();
    case H5R_OBJECT:         return Val_int(0);
    case H5R_DATASET_REGION: return Val_int(1);
    default: caml_failwith("unrecognized H5R_type_t");
  }
}

value hdf5_h5r_create(value loc_id_v, value name_v, value space_id_opt_v,
  value ref_type_v)
{
  CAMLparam4(loc_id_v, name_v, space_id_opt_v, ref_type_v);
  CAMLlocal1(v);
  H5R_type_t ref_type = H5R_type_val(ref_type_v);
  v = caml_alloc_string(ref_type == H5R_DATASET_REGION ? 12 : 8);
  raise_if_fail(H5Rcreate(String_val(v), Hid_val(loc_id_v), String_val(name_v), ref_type,
    H5S_opt_val(space_id_opt_v)));
  CAMLreturn(v);
}

value hdf5_h5r_dereference(value obj_id_v, value ref_type_v, value ref_v)
{
  CAMLparam3(obj_id_v, ref_type_v, ref_v);
  CAMLreturn(alloc_hid(H5Rdereference(Hid_val(obj_id_v), H5R_type_val(ref_type_v),
    String_val(ref_v))));
}

value hdf5_h5r_get_region(value loc_id_v, value ref_type_v, value ref_v)
{
  CAMLparam3(loc_id_v, ref_type_v, ref_v);
  CAMLreturn(alloc_h5s(H5Rget_region(Hid_val(loc_id_v), H5R_type_val(ref_type_v),
    String_val(ref_v))));
}
