#include <assert.h>
#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include "hdf5.h"
#include "hdf5_caml.h"

H5L_type_t H5L_type_val(value type)
{
  switch (Int_val(type))
  {
    case  0: return H5L_TYPE_HARD;
    case  1: return H5L_TYPE_SOFT;
    case  2: return H5L_TYPE_EXTERNAL;
    case  3: return H5L_TYPE_MAX;
    default: caml_failwith("unrecognized H5L_type_t");
  }
}

value Val_h5l_type(H5L_type_t layout)
{
  switch (layout)
  {
    case H5L_TYPE_ERROR:    fail();
    case H5L_TYPE_HARD:     return Val_int(0);
    case H5L_TYPE_SOFT:     return Val_int(1);
    case H5L_TYPE_EXTERNAL: return Val_int(2);
    case H5L_TYPE_MAX:      return Val_int(3);
    default: caml_failwith("unrecognized H5L_type_t");
  }
}

value Val_h5l_info(const H5L_info_t *info)
{
  CAMLparam0();
  CAMLlocal1(info_v);
  info_v = caml_alloc_tuple(5);
  Store_field(info_v, 0, Val_h5l_type(info->type));
  Store_field(info_v, 1, Val_bool(info->corder_valid));
  Store_field(info_v, 2, Val_int(info->corder));
  Store_field(info_v, 3, Val_h5t_cset(info->cset));
  if (info->type == H5L_TYPE_HARD)
    Store_field(info_v, 4, alloc_hid(info->u.address));
  else
    Store_field(info_v, 4, Val_int(0));
  CAMLreturn(info_v);
}

static struct custom_operations h5l_ops = {
  "hdf5.h5l",
  custom_finalize_default,
  custom_compare_default,
  custom_compare_ext_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default
};

static value alloc_h5l(hid_t id)
{
  value v;
  raise_if_fail(id);
  v = caml_alloc_custom(&h5l_ops, sizeof(hid_t), 0, 1);
  Hid_val(v) = id;
  return v;
}

value hdf5_h5l_create_hard(value obj_loc_v, value obj_name_v, value link_loc_v,
  value lcpl_v, value lapl_v, value link_name_v)
{
  CAMLparam5(obj_loc_v, obj_name_v, link_loc_v, lcpl_v, lapl_v);
  CAMLxparam1(link_name_v);
  CAMLreturn(alloc_h5l(H5Lcreate_hard(Hid_val(obj_loc_v), String_val(obj_name_v),
    Hid_val(link_loc_v), String_val(link_name_v), H5P_opt_val(lcpl_v),
    H5P_opt_val(lapl_v))));
}

value hdf5_h5l_create_hard_bytecode(value *argv, int argn)
{
  assert(argn == 6);
  return hdf5_h5l_create_hard(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}

value hdf5_h5l_exists(value loc_v, value lapl_v, value name_v)
{
  CAMLparam3(loc_v, lapl_v, name_v);
  CAMLreturn(Val_htri(H5Lexists(Hid_val(loc_v), String_val(name_v),
    H5P_opt_val(lapl_v))));
}

void hdf5_h5l_move(value src_loc_v, value src_name_v, value dest_loc_v, value lcpl_v,
  value lapl_v, value dest_name_v)
{
  CAMLparam5(src_loc_v, src_name_v, dest_loc_v, lcpl_v, lapl_v);
  CAMLxparam1(dest_name_v);
  raise_if_fail(H5Lmove(Hid_val(src_loc_v), String_val(src_name_v), Hid_val(dest_loc_v),
    String_val(dest_name_v), H5P_opt_val(lcpl_v), H5P_opt_val(lapl_v)));
  CAMLreturn0;
}

void hdf5_h5l_move_bytecode(value *argv, int argn)
{
  assert(argn == 6);
  hdf5_h5l_move(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}

void hdf5_h5l_copy(value src_loc_v, value src_name_v, value dest_loc_v, value lcpl_v,
  value lapl_v, value dest_name_v)
{
  CAMLparam5(src_loc_v, src_name_v, dest_loc_v, lcpl_v, lapl_v);
  CAMLxparam1(dest_name_v);
  raise_if_fail(H5Lcopy(Hid_val(src_loc_v), String_val(src_name_v), Hid_val(dest_loc_v),
    String_val(dest_name_v), H5P_opt_val(lcpl_v), H5P_opt_val(lapl_v)));
  CAMLreturn0;
}

void hdf5_h5l_copy_bytecode(value *argv, int argn)
{
  assert(argn == 6);
  hdf5_h5l_copy(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}

void hdf5_h5l_delete(value loc_v, value lapl_v, value name_v)
{
  CAMLparam3(loc_v, lapl_v, name_v);
  raise_if_fail(H5Ldelete(Hid_val(loc_v), String_val(name_v), H5P_opt_val(lapl_v)));
  CAMLreturn0;
}

struct operator_data {
  value *callback;
  value *operator_data;
  value *exception;
};

herr_t hdf5_h5l_operator(hid_t group, const char *name, const H5L_info_t *info,
  void *op_data)
{
  CAMLparam0();
  CAMLlocal5(ret, info_v, address_v, args0, args1);
  CAMLlocal2(args2, args3);
  value args[4];

  struct operator_data *operator_data = op_data;
  args0 = alloc_h5l(group);
  args1 = caml_copy_string(name);
  args2 = Val_h5l_info(info);
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

value hdf5_h5l_iterate(value group_v, value index_type_v, value order_v, value idx_v,
  value op_v, value op_data_v)
{
  CAMLparam5(group_v, index_type_v, order_v, idx_v, op_v);
  CAMLxparam1(op_data_v);
  CAMLlocal1(exception);

  struct operator_data op_data;
  hsize_t idx, ret;
  op_data.callback      = &op_v;
  op_data.operator_data = &op_data_v;
  op_data.exception     = &exception;
  idx = Is_block(idx_v) ? Int_val(Field(Field(idx_v, 0), 0)) : 0;
  exception = Val_unit;

  ret = H5Literate(Hid_val(group_v), H5_index_val(index_type_v),
    H5_iter_order_val(order_v), Is_block(idx_v) ? &idx : NULL, hdf5_h5l_operator,
    &op_data);
  if (Is_block(idx_v))
    Store_field(Field(idx_v, 0), 0, Val_int(idx));
  if (exception != Val_unit)
    caml_raise(exception);
  CAMLreturn(Val_h5_iter(ret));
}

value hdf5_h5l_iterate_bytecode(value *argv, int argn)
{
  assert(argn == 6);
  return hdf5_h5l_iterate(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}

value hdf5_h5l_iterate_by_name(value loc_v, value group_name_v, value index_type_v,
  value order_v, value idx_v, value op_v, value lapl_v, value op_data_v)
{
  CAMLparam5(loc_v, group_name_v, index_type_v, order_v, idx_v);
  CAMLxparam3(op_v, lapl_v, op_data_v);
  CAMLlocal1(exception);

  struct operator_data op_data;
  hsize_t idx, ret;
  op_data.callback      = &op_v;
  op_data.operator_data = &op_data_v;
  op_data.exception     = &exception;
  idx = Is_block(idx_v) ? Int_val(Field(Field(idx_v, 0), 0)) : 0;
  exception = Val_unit;

  ret = H5Literate_by_name(Hid_val(loc_v), String_val(group_name_v),
    H5_index_val(index_type_v), H5_iter_order_val(order_v),
    Is_block(idx_v) ? &idx : NULL, hdf5_h5l_operator, &op_data, H5P_opt_val(lapl_v));
  if (Is_block(idx_v))
    Store_field(Field(idx_v, 0), 0, Val_int(idx));
  if (exception != Val_unit)
    caml_raise(exception);
  CAMLreturn(Val_h5_iter(ret));
}

value hdf5_h5l_iterate_by_name_bytecode(value *argv, int argn)
{
  assert(argn == 8);
  return hdf5_h5l_iterate_by_name(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5],
    argv[6], argv[7]);
}

value hdf5_h5l_get_name_by_idx(value loc_v, value group_name_v, value index_field_v,
  value order_v, value lapl_v, value n_v)
{
  CAMLparam5(loc_v, group_name_v, index_field_v, order_v, lapl_v);
  CAMLxparam1(n_v);
  CAMLlocal1(name_v);
  hid_t loc_id = Hid_val(loc_v), lapl_id = H5P_opt_val(lapl_v);
  const char *group_name = String_val(group_name_v);
  H5_index_t index_field = H5_index_val(index_field_v);
  H5_iter_order_t order = H5_iter_order_val(order_v);
  hsize_t n = Int_val(n_v);
  char *name;
  ssize_t size;
  size = H5Lget_name_by_idx(loc_id, group_name, index_field, order, n, NULL, 0, lapl_id);
  if (size < 0)
    fail();
  size++;
  name = malloc(size);
  if (name == NULL)
    caml_raise_out_of_memory();
  size = H5Lget_name_by_idx(loc_id, group_name, index_field, order, n, name, size,
    lapl_id);
  if (size < 0)
  {
    free(name);
    fail();
  }
  name_v = caml_copy_string(name);
  free(name);
  CAMLreturn(name_v);
}

value hdf5_h5l_get_name_by_idx_bytecode(value *argv, int argn)
{
  assert(argn == 6);
  return hdf5_h5l_get_name_by_idx(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}
