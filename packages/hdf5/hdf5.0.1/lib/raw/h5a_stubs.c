#include <assert.h>
#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/custom.h>
#include <caml/bigarray.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include "hdf5.h"
#include "hdf5_caml.h"

void h5a_finalize(value v)
{
  if (!Hid_closed(v))
    H5Aclose(Hid_val(v));
  Hid_closed(v) = true;
}

static struct custom_operations h5a_ops = {
  "hdf5.h5a",
  h5a_finalize,
  custom_compare_default,
  custom_compare_ext_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default
};

static value alloc_h5a(hid_t id)
{
  value v;
  raise_if_fail(id);
  v = caml_alloc_custom(&h5a_ops, sizeof(hid_t) + sizeof(bool), 0, 1);
  Hid_val(v) = id;
  Hid_closed(v) = false;
  return v;
}

H5A_info_t H5A_info_val(value info_v)
{
  CAMLparam1(info_v);
  H5A_info_t info;
  info.corder_valid = Int_val(Field(info_v, 0));
  info.corder = Int_val(Field(info_v, 1));
  info.cset = H5T_cset_val(Field(info_v, 2));
  info.data_size = Int_val(Field(info_v, 3));
  CAMLreturnT(H5A_info_t, info);
}

value Val_h5a_info(H5A_info_t info)
{
  CAMLparam0();
  CAMLlocal1(info_v);
  info_v = caml_alloc_tuple(4);
  Store_field(info_v, 0, Val_int(info.corder_valid));
  Store_field(info_v, 1, Val_int(info.corder));
  Store_field(info_v, 2, Val_h5t_cset(info.cset));
  Store_field(info_v, 3, Val_int(info.data_size));
  CAMLreturn(info_v);
}

value hdf5_h5a_create(value loc_v, value attr_name_v, value type_v, value acpl_v,
  value aapl_v, value space_v)
{
  CAMLparam5(loc_v, attr_name_v, type_v, acpl_v, aapl_v);
  CAMLxparam1(space_v);
  CAMLreturn(alloc_h5a(H5Acreate2(Hid_val(loc_v), String_val(attr_name_v),
    Hid_val(type_v), Hid_val(space_v), H5P_opt_val(acpl_v),
    H5P_opt_val(aapl_v))));
}

value hdf5_h5a_create_bytecode(value *argv, int argn)
{
  assert(argn == 6);
  return hdf5_h5a_create(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}

value hdf5_h5a_create_by_name(value loc_v, value obj_name_v, value attr_name_v,
  value type_v, value acpl_v, value aapl_v, value lapl_v, value space_v)
{
  CAMLparam5(loc_v, obj_name_v, attr_name_v, type_v, acpl_v);
  CAMLxparam3(aapl_v, lapl_v, space_v);
  CAMLreturn(alloc_h5a(H5Acreate_by_name(Hid_val(loc_v), String_val(obj_name_v),
    String_val(attr_name_v), Hid_val(type_v), Hid_val(space_v), H5P_opt_val(acpl_v),
    H5P_opt_val(aapl_v), H5P_opt_val(lapl_v))));
}

value hdf5_h5a_create_by_name_bytecode(value *argv, int argn)
{
  assert(argn == 8);
  return hdf5_h5a_create_by_name(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5],
    argv[6], argv[7]);
}

value hdf5_h5a_open(value obj_v, value aapl_v, value attr_name_v)
{
  CAMLparam3(obj_v, aapl_v, attr_name_v);
  CAMLreturn(alloc_h5a(H5Aopen(Hid_val(obj_v), String_val(attr_name_v),
    H5P_opt_val(aapl_v))));
}

value hdf5_h5a_open_by_name(value loc_v, value aapl_v, value lapl_v, value obj_name_v,
  value attr_name_v)
{
  CAMLparam5(loc_v, aapl_v, lapl_v, obj_name_v, attr_name_v);
  CAMLreturn(alloc_h5a(H5Aopen_by_name(Hid_val(loc_v), String_val(obj_name_v),
    String_val(attr_name_v), H5P_opt_val(aapl_v), H5P_opt_val(lapl_v))));
}

value hdf5_h5a_open_name(value loc_v, value name_v)
{
  CAMLparam2(loc_v, name_v);
  CAMLreturn(alloc_h5a(H5Aopen_name(Hid_val(loc_v), String_val(name_v))));
}

value hdf5_h5a_open_by_idx(value loc_v, value aapl_v, value lapl_v, value obj_name_v,
  value idx_type_v, value order_v, value n_v)
{
  CAMLparam5(loc_v, aapl_v, lapl_v, obj_name_v, idx_type_v);
  CAMLxparam2(order_v, n_v);
  CAMLreturn(alloc_h5a(H5Aopen_by_idx(Hid_val(loc_v), String_val(obj_name_v),
    H5_index_val(idx_type_v), H5_iter_order_val(order_v), Int_val(n_v),
    H5P_opt_val(aapl_v), H5P_opt_val(lapl_v))));
}

value hdf5_h5a_open_by_idx_bytecode(value *argv, int argn)
{
  assert(argn == 7);
  return hdf5_h5a_open_by_idx(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5],
    argv[6]);
}

value hdf5_h5a_open_idx(value loc_v, value idx_v)
{
  CAMLparam2(loc_v, idx_v);
  CAMLreturn(alloc_h5a(H5Aopen_idx(Hid_val(loc_v), Int_val(idx_v))));
}

value hdf5_h5a_exists(value obj_v, value attr_name_v)
{
  CAMLparam2(obj_v, attr_name_v);
  CAMLreturn(Val_htri(H5Aexists(Hid_val(obj_v), String_val(attr_name_v))));
}

value hdf5_h5a_exists_by_name(value loc_v, value obj_name_v, value lapl_v,
  value attr_name_v)
{
  CAMLparam4(loc_v, obj_name_v, lapl_v, attr_name_v);
  CAMLreturn(Val_htri(H5Aexists_by_name(Hid_val(loc_v), String_val(obj_name_v),
    String_val(attr_name_v), H5P_opt_val(lapl_v))));
}

void hdf5_h5a_rename(value loc_v, value old_attr_name_v, value new_attr_name_v)
{
  CAMLparam3(loc_v, old_attr_name_v, new_attr_name_v);
  raise_if_fail(H5Arename(Hid_val(loc_v), String_val(old_attr_name_v),
    String_val(new_attr_name_v)));
  CAMLreturn0;
}

void hdf5_h5a_rename_by_name(value loc_v, value obj_name_v, value lapl_v,
  value old_attr_name_v, value new_attr_name_v)
{
  CAMLparam5(loc_v, obj_name_v, lapl_v, old_attr_name_v, new_attr_name_v);
  raise_if_fail(H5Arename_by_name(Hid_val(loc_v), String_val(obj_name_v),
    String_val(old_attr_name_v), String_val(new_attr_name_v), H5P_opt_val(lapl_v)));
  CAMLreturn0;
}

void hdf5_h5a_write(value attr_v, value mem_type_v, value buf_v)
{
  CAMLparam3(attr_v, mem_type_v, buf_v);
  const void* buf;
  if (Is_long(buf_v))
    caml_invalid_argument("H5a.write: immediate values not allowed");
  else if (Tag_hd(Hd_val(buf_v)) == Custom_tag && Custom_ops_val(buf_v) == caml_ba_ops)
    buf = Caml_ba_data_val(buf_v);
  else
    buf = (const void*) buf_v;
  raise_if_fail(H5Awrite(Hid_val(attr_v), Hid_val(mem_type_v), buf));
  CAMLreturn0;
}

void hdf5_h5a_read(value attr_v, value mem_type_v, value buf_v)
{
  CAMLparam3(attr_v, mem_type_v, buf_v);
  void* buf;
  if (Is_long(buf_v))
    caml_invalid_argument("H5a.read: immediate values not allowed");
  else if (Tag_hd(Hd_val(buf_v)) == Custom_tag && Custom_ops_val(buf_v) == caml_ba_ops)
    buf = Caml_ba_data_val(buf_v);
  else
    buf = (void*) buf_v;
  raise_if_fail(H5Aread(Hid_val(attr_v), Hid_val(mem_type_v), buf));
  CAMLreturn0;
}

void hdf5_h5a_read_vl(value attr_v, value mem_type_v, value buf_v)
{
  CAMLparam3(attr_v, mem_type_v, buf_v);
  void* buf;
  char* s;
  mlsize_t i;
  if (Is_long(buf_v))
    caml_invalid_argument("H5a.read: immediate values not allowed");
  else if (Tag_hd(Hd_val(buf_v)) == Custom_tag && Custom_ops_val(buf_v) == caml_ba_ops)
    caml_invalid_argument("H5a.read: bigarrays not allowed");
  else
    buf = (void*) buf_v;
  raise_if_fail(H5Aread(Hid_val(attr_v), Hid_val(mem_type_v), buf));
  for (i = 0; i < Wosize_val(buf_v); i++)
  {
    s = ((char**) buf)[i];
    Store_field(buf_v, i, caml_copy_string(s));
    free(s);
  }
  CAMLreturn0;
}

void hdf5_h5a_close(value attr_v)
{
  CAMLparam1(attr_v);
  raise_if_fail(H5Aclose(Hid_val(attr_v)));
  Hid_closed(attr_v) = true;
  CAMLreturn0;
}

struct operator_data {
  value *callback;
  value *operator_data;
  value *exception;
};

herr_t hdf5_h5a_operator(hid_t location_id, const char *attr_name,
  const H5A_info_t *ainfo, void *op_data)
{
  CAMLparam0();
  CAMLlocal5(ret, args0, args1, args2, args3);
  struct operator_data *operator_data = op_data;
  value args[4];

  args0 = alloc_hid(location_id);
  args1 = caml_copy_string(attr_name);
  args2 = Val_h5a_info(*ainfo);
  args3 = *operator_data->operator_data;
  args[0] = args0;
  args[1] = args1;
  args[2] = args2;
  args[3] = args3;
  ret = caml_callbackN_exn(*operator_data->callback, 4, args);
  if (Is_exception_result(ret))
  {
    *(operator_data->exception) = Extract_exception(ret);
    return -1;
  }
  CAMLreturnT(herr_t, H5_iter_val(ret));
}

value hdf5_h5a_iterate(value obj_v, value idx_type_opt_v, value order_opt_v, value n_v,
  value op_v, value op_data_v)
{
  CAMLparam5(obj_v, idx_type_opt_v, order_opt_v, n_v, op_v);
  CAMLxparam1(op_data_v);
  CAMLlocal1(exception);
  hsize_t n, ret;

  struct operator_data op;
  op.callback = &op_v;
  op.operator_data = &op_data_v;
  op.exception = &exception;
  n = Is_block(n_v) ? Int_val(Field(Field(n_v, 0), 0)) : 0;
  exception = Val_unit;

  ret = H5Aiterate(Hid_val(obj_v), H5_index_opt_val(idx_type_opt_v),
    H5_iter_order_opt_val(order_opt_v), Is_block(n_v) ? &n : NULL, hdf5_h5a_operator,
    &op);
  if (Is_block(n_v))
    Store_field(Field(n_v, 0), 0, Val_int(n));
  if (exception != Val_unit)
    caml_raise(exception);
  CAMLreturn(Val_h5_iter(ret));
}

value hdf5_h5a_iterate_bytecode(value *argv, int argn)
{
  assert(argn == 6);
  return hdf5_h5a_iterate(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}

value hdf5_h5a_iterate_by_name(value loc_v, value obj_name_v, value idx_type_opt_v,
  value order_opt_v, value n_v, value lapd_v, value op_v, value op_data_v)
{
  CAMLparam5(loc_v, obj_name_v, idx_type_opt_v, order_opt_v, n_v);
  CAMLxparam3(lapd_v, op_v, op_data_v);
  CAMLlocal1(exception);
  hsize_t n, ret;

  struct operator_data op;
  op.callback = &op_v;
  op.operator_data = &op_data_v;
  op.exception = &exception;
  n = Is_block(n_v) ? Int_val(Field(Field(n_v, 0), 0)) : 0;
  exception = Val_unit;

  ret = H5Aiterate_by_name(Hid_val(loc_v), String_val(obj_name_v),
    H5_index_opt_val(idx_type_opt_v), H5_iter_order_opt_val(order_opt_v),
    Is_block(n_v) ? &n : NULL, hdf5_h5a_operator, &op, H5P_opt_val(lapd_v));
  if (Is_block(n_v))
    Store_field(Field(n_v, 0), 0, Val_int(n));
  if (exception != Val_unit)
    caml_raise(exception);
  CAMLreturn(Val_h5_iter(ret));
}

value hdf5_h5a_iterate_by_name_bytecode(value *argv, int argn)
{
  assert(argn == 8);
  return hdf5_h5a_iterate_by_name(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5],
    argv[6], argv[7]);
}

void hdf5_h5a_delete(value loc_v, value attr_name_v)
{
  CAMLparam2(loc_v, attr_name_v);
  raise_if_fail(H5Adelete(Hid_val(loc_v), String_val(attr_name_v)));
  CAMLreturn0;
}

void hdf5_h5a_delete_by_name(value loc_v, value lapl_v, value obj_name_v,
  value attr_name_v)
{
  CAMLparam4(loc_v, lapl_v, obj_name_v, attr_name_v);
  raise_if_fail(H5Adelete_by_name(Hid_val(loc_v), String_val(obj_name_v),
    String_val(attr_name_v), H5P_opt_val(lapl_v)));
  CAMLreturn0;
}

void hdf5_h5a_delete_by_idx(value loc_v, value obj_name_v, value idx_type_opt_v,
  value order_opt_v, value lapl_v, value n_v)
{
  CAMLparam5(loc_v, obj_name_v, idx_type_opt_v, order_opt_v, lapl_v);
  CAMLxparam1(n_v);
  raise_if_fail(H5Adelete_by_idx(Hid_val(loc_v), String_val(obj_name_v),
    H5_index_opt_val(idx_type_opt_v), H5_iter_order_opt_val(order_opt_v), Int_val(n_v),
    H5P_opt_val(lapl_v)));
  CAMLreturn0;
}

void hdf5_h5a_delete_by_idx_bytecode(value *argv, int argn)
{
  assert(argn == 6);
  hdf5_h5a_delete_by_idx(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}

value hdf5_h5a_get_info(value attr_v)
{
  CAMLparam1(attr_v);
  H5A_info_t ainfo;
  raise_if_fail(H5Aget_info(Hid_val(attr_v), &ainfo));
  CAMLreturn(Val_h5a_info(ainfo));
}

value hdf5_h5a_get_info_by_name(value loc_v, value obj_name_v, value lapl_v,
  value attr_name_v)
{
  CAMLparam4(loc_v, obj_name_v, lapl_v, attr_name_v);
  H5A_info_t ainfo;
  raise_if_fail(H5Aget_info_by_name(Hid_val(loc_v), String_val(obj_name_v),
    String_val(attr_name_v), &ainfo, H5P_opt_val(lapl_v)));
  CAMLreturn(Val_h5a_info(ainfo));
}

value hdf5_h5a_get_info_by_idx(value loc_v, value obj_name_v, value idx_type_opt_v,
  value order_opt_v, value lapl_v, value n_v)
{
  CAMLparam5(loc_v, obj_name_v, idx_type_opt_v, order_opt_v, lapl_v);
  CAMLxparam1(n_v);
  H5A_info_t ainfo;
  raise_if_fail(H5Aget_info_by_idx(Hid_val(loc_v), String_val(obj_name_v),
    H5_index_opt_val(idx_type_opt_v), H5_iter_order_opt_val(order_opt_v), Int_val(n_v),
    &ainfo, H5P_opt_val(lapl_v)));
  CAMLreturn(Val_h5a_info(ainfo));
}

value hdf5_h5a_get_info_by_idx_bytecode(value *argv, int argn)
{
  assert(argn == 6);
  return hdf5_h5a_get_info_by_idx(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}

value hdf5_h5a_get_num_attrs(value loc_v)
{
  CAMLparam1(loc_v);
  CAMLreturn(Val_int(H5Aget_num_attrs(Hid_val(loc_v))));
}

value hdf5_h5a_get_name(value attr_v)
{
  CAMLparam1(attr_v);
  CAMLlocal1(name_v);
  hid_t attr_id;
  char* buf;
  ssize_t size;

  attr_id = Hid_val(attr_v);
  size = H5Aget_name(attr_id, 0, NULL);
  if (size < 0)
    fail();
  buf = malloc(size);
  if (buf == NULL)
    caml_raise_out_of_memory();
  size = H5Aget_name(attr_id, size, buf);
  if (size < 0)
  {
    free(buf);
    fail();
  }
  name_v = caml_copy_string(buf);
  free(buf);
  CAMLreturn(name_v);
}

value hdf5_h5a_get_create_plist(value attr_v)
{
  CAMLparam1(attr_v);
  CAMLreturn(alloc_h5p(H5Aget_create_plist(Hid_val(attr_v))));
}

value hdf5_h5a_get_space(value attr_v)
{
  CAMLparam1(attr_v);
  CAMLreturn(alloc_h5s(H5Aget_space(Hid_val(attr_v))));
}

value hdf5_h5a_get_type(value attr_v)
{
  CAMLparam1(attr_v);
  CAMLreturn(alloc_h5t(H5Aget_type(Hid_val(attr_v))));
}

value hdf5_h5a_get_storage_size(value attr_v)
{
  CAMLparam1(attr_v);
  hsize_t size = H5Aget_storage_size(Hid_val(attr_v));
  if (size == 0)
    fail();
  CAMLreturn(Val_int(size));
}

value hdf5_h5a_get_name_by_idx(value loc_v, value obj_name_v, value idx_type_opt_v,
  value order_opt_v, value lapl_v, value n_v)
{
  CAMLparam5(loc_v, obj_name_v, idx_type_opt_v, order_opt_v, lapl_v);
  CAMLxparam1(n_v);
  CAMLlocal1(name_v);
  char *buf;
  ssize_t size;

  size = H5Aget_name_by_idx(Hid_val(loc_v), String_val(obj_name_v),
    H5_index_opt_val(idx_type_opt_v), H5_iter_order_opt_val(order_opt_v), Int_val(n_v),
    NULL, 0, H5P_opt_val(lapl_v));
  if (size < 0)
    fail();
  buf = malloc(size);
  if (buf == NULL)
    caml_raise_out_of_memory();
  size = H5Aget_name_by_idx(Hid_val(loc_v), String_val(obj_name_v),
    H5_index_opt_val(idx_type_opt_v), H5_iter_order_opt_val(order_opt_v), Int_val(n_v),
    buf, size, H5P_opt_val(lapl_v));
  if (size < 0)
  {
    free(buf);
    fail();
  }
  name_v = caml_copy_string(buf);
  free(buf);
  CAMLreturn(name_v);
}

value hdf5_h5a_get_name_by_idx_bytecode(value *argv, int argn)
{
  assert(argn == 6);
  return hdf5_h5a_get_name_by_idx(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}
