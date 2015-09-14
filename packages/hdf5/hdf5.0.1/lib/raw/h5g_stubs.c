#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include "hdf5.h"
#include "hdf5_caml.h"

void h5g_finalize(value v)
{
  if (!Hid_closed(v))
    H5Gclose(Hid_val(v));
  Hid_closed(v) = true;
}

static struct custom_operations h5g_ops = {
  "hdf5.h5g",
  h5g_finalize,
  custom_compare_default,
  custom_compare_ext_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default
};

static value alloc_h5g(hid_t id, bool close)
{
  value v;
  raise_if_fail(id);
  v = caml_alloc_custom(&h5g_ops, sizeof(hid_t) + sizeof(bool), 0, 1);
  Hid_val(v) = id;
  Hid_closed(v) = !close;
  return v;
}

H5G_storage_type_t H5G_storage_type_val(value st)
{
  switch (Int_val(st))
  {
    case 0: return H5G_STORAGE_TYPE_SYMBOL_TABLE;
    case 1: return H5G_STORAGE_TYPE_COMPACT;
    case 2: return H5G_STORAGE_TYPE_DENSE;
    default: caml_failwith("unrecognized H5G_storage_type_t");
  }
}

value Val_h5g_storage_type(H5G_storage_type_t st)
{
  switch (st)
  {
    case H5G_STORAGE_TYPE_UNKNOWN:      fail();
    case H5G_STORAGE_TYPE_SYMBOL_TABLE: return Val_int(0);
    case H5G_STORAGE_TYPE_COMPACT:      return Val_int(1);
    case H5G_STORAGE_TYPE_DENSE:        return Val_int(2);
    default: caml_failwith("unrecognized H5G_storage_type_t");
  }
}

H5G_info_t H5G_info_val(value info_v)
{
  CAMLparam1(info_v);
  H5G_info_t info;
  info.storage_type = H5G_storage_type_val(Field(info_v, 0));
  info.nlinks       = Int_val(Field(info_v, 1));
  info.max_corder   = Int_val(Field(info_v, 2));
  info.mounted      = Bool_val(Field(info_v, 3));
  CAMLreturnT(H5G_info_t, info);
}

value Val_h5g_info(H5G_info_t *info)
{
  CAMLparam0();
  CAMLlocal1(info_v);
  info_v = caml_alloc_tuple(4);
  Store_field(info_v, 0, Val_h5g_storage_type(info->storage_type));
  Store_field(info_v, 1, Val_int(info->nlinks));
  Store_field(info_v, 2, Val_int(info->max_corder));
  Store_field(info_v, 3, Val_bool(info->mounted));
  CAMLreturn(info_v);
}

void hdf5_h5g_close(value group_v)
{
  CAMLparam1(group_v);
  raise_if_fail(H5Gclose(Hid_val(group_v)));
  Hid_closed(group_v) = true;
  CAMLreturn0;
}

value hdf5_h5g_create(value loc_v, value lcpl_v, value gcpl_v, value gapl_v, value name_v)
{
  CAMLparam5(loc_v, lcpl_v, gcpl_v, gapl_v, name_v);
  CAMLreturn(alloc_h5g(H5Gcreate2(Hid_val(loc_v), String_val(name_v), H5P_opt_val(lcpl_v),
    H5P_opt_val(gcpl_v), H5P_opt_val(gapl_v)), true));
}

value hdf5_h5g_open(value loc_v, value gapl_v, value name_v)
{
  CAMLparam3(loc_v, gapl_v, name_v);
  CAMLreturn(alloc_h5g(H5Gopen2(Hid_val(loc_v), String_val(name_v),
    H5P_opt_val(gapl_v)), true));
}

void hdf5_h5g_link(value loc_v, value link_type_v, value current_name_v,
  value new_name_v)
{
  CAMLparam4(loc_v, link_type_v, current_name_v, new_name_v);
  raise_if_fail(H5Glink(Hid_val(loc_v), H5L_type_val(link_type_v),
    String_val(current_name_v), String_val(new_name_v)));
  CAMLreturn0;
}

void hdf5_h5g_unlink(value loc_id_v, value name_v)
{
  CAMLparam2(loc_id_v, name_v);
  raise_if_fail(H5Gunlink(Hid_val(loc_id_v), String_val(name_v)));
  CAMLreturn0;
}

void hdf5_h5g_set_comment(value loc_id_v, value name_v, value comment_v)
{
  CAMLparam3(loc_id_v, name_v, comment_v);
  raise_if_fail(H5Gset_comment(Hid_val(loc_id_v), String_val(name_v),
    String_val(comment_v)));
  CAMLreturn0;
}

value hdf5_h5g_get_comment(value loc_id_v, value name_v)
{
  CAMLparam2(loc_id_v, name_v);
  CAMLlocal1(v);
  int bufsize;

  bufsize = H5Gget_comment(Hid_val(loc_id_v), String_val(name_v), 0, NULL);
  v = caml_alloc_string(bufsize);
  H5Gget_comment(Hid_val(loc_id_v), String_val(name_v), bufsize, String_val(v));
  CAMLreturn(v);
}

value hdf5_h5g_get_info(value group_v)
{
  CAMLparam1(group_v);
  H5G_info_t group_info;
  raise_if_fail(H5Gget_info(Hid_val(group_v), &group_info));
  CAMLreturn(Val_h5g_info(&group_info));
}

struct operator_data {
  value *callback;
  value *operator_data;
  value *exception;
};

herr_t hdf5_h5g_operator(hid_t group, const char *name, void *op_data)
{
  CAMLparam0();
  CAMLlocal4(ret, args0, args1, args2);
  value args[3];
  struct operator_data *operator_data = op_data;
  args0 = alloc_h5g(group, false);
  args1 = caml_copy_string(name);
  args2 = *operator_data->operator_data;
  args[0] = args0;
  args[1] = args1;
  args[2] = args2;
  ret = caml_callbackN_exn(*operator_data->callback, 3, args);
  if (Is_exception_result(ret))
  {
    *(operator_data->exception) = Extract_exception(ret);
    return -1;
  }
  CAMLreturnT(herr_t, H5_iter_val(ret));
}

value hdf5_h5g_iterate(value loc_id_v, value name_v, value idx_v, value operator_v,
  value operator_data_v)
{
  CAMLparam5(loc_id_v, name_v, idx_v, operator_v, operator_data_v);
  CAMLlocal1(exception);

  struct operator_data operator_data;
  int idx, ret;
  operator_data.callback = &operator_v;
  operator_data.operator_data = &operator_data_v;
  operator_data.exception = &exception;
  idx = Is_block(idx_v) ? Int_val(Field(Field(idx_v, 0), 0)) : 0;
  exception = Val_unit;

  ret = H5Giterate(Hid_val(loc_id_v), String_val(name_v),
        Is_block(idx_v) ? &idx : NULL, hdf5_h5g_operator, &operator_data);
  if (Is_block(idx_v))
    Store_field(Field(idx_v, 0), 0, Val_int(idx));
  if (exception != Val_unit)
    caml_raise(exception);
  CAMLreturn(Val_h5_iter(ret));
}
