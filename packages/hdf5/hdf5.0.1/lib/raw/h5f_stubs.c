#include <assert.h>
#include <stdbool.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include "hdf5.h"
#include "hdf5_caml.h"

#define H5F_val(v) *((hid_t*) Data_custom_val(v))
#define H5F_closed(v) *((bool*) ((char*) Data_custom_val(v) + sizeof(hid_t)))

void h5f_finalize(value v)
{
  if (!H5F_closed(v))
    H5Fclose(H5F_val(v));
  H5F_closed(v) = true;
}

static struct custom_operations h5f_ops = {
  "hdf5.h5f",
  h5f_finalize,
  custom_compare_default,
  custom_compare_ext_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default
};

static value alloc_h5f(hid_t id)
{
  value v;
  raise_if_fail(id);
  v = caml_alloc_custom(&h5f_ops, sizeof(hid_t) + sizeof(bool), 0, 1);
  H5F_val(v) = id;
  H5F_closed(v) = false;
  return v;
}

unsigned acc_val(value v)
{
  CAMLparam0();
  CAMLlocal1(h);
  unsigned flags = 0;

  while (Is_block(v))
  {
    assert(Tag_val(v) == 0);
    h = Field(v, 0);
    v = Field(v, 1);
    assert(Is_long(h));
    switch (Long_val(h))
    {
      case 0: flags |= H5F_ACC_RDONLY ; break;
      case 1: flags |= H5F_ACC_RDWR   ; break;
      case 2: flags |= H5F_ACC_TRUNC  ; break;
      case 3: flags |= H5F_ACC_EXCL   ; break;
      case 4: flags |= H5F_ACC_DEBUG  ; break;
      case 5: flags |= H5F_ACC_CREAT  ; break;
      case 6: flags |= H5F_ACC_DEFAULT; break;
      default: caml_failwith("unrecognized acc");
    }
  }
  assert(Int_val(v) == 0);
  CAMLreturnT(unsigned, flags);
}

unsigned obj_val(value v)
{
  CAMLparam0();
  CAMLlocal1(h);
  unsigned flags = 0;

  while (Is_block(v))
  {
    assert(Tag_val(v) == 0);
    h = Field(v, 0);
    v = Field(v, 1);
    assert(Is_long(h));
    switch (Long_val(h))
    {
      case 0: flags |= H5F_OBJ_FILE    ; break;
      case 1: flags |= H5F_OBJ_DATASET ; break;
      case 2: flags |= H5F_OBJ_GROUP   ; break;
      case 3: flags |= H5F_OBJ_DATATYPE; break;
      case 4: flags |= H5F_OBJ_ATTR    ; break;
      case 5: flags |= H5F_OBJ_ALL     ; break;
      case 6: flags |= H5F_OBJ_LOCAL   ; break;
      default: caml_failwith("unrecognized obj");
    }
  }
  assert(Int_val(v) == 0);
  CAMLreturnT(unsigned, flags);
}

H5F_scope_t H5F_scope_val(value v)
{
  switch (Int_val(v))
  {
    case 0: return H5F_SCOPE_LOCAL;
    case 1: return H5F_SCOPE_GLOBAL;
    default: caml_failwith("unrecognized H5F_scope_t");
  }
}

H5F_close_degree_t H5F_close_degree_val(value v)
{
  switch (Int_val(v))
  {
    case 0: return H5F_CLOSE_DEFAULT;
    case 1: return H5F_CLOSE_WEAK;
    case 2: return H5F_CLOSE_SEMI;
    case 3: return H5F_CLOSE_STRONG;
    default: caml_failwith("unrecognized H5F_close_degree_t");
  }
}

H5F_info_t H5F_info_val(value info_v)
{
  CAMLparam1(info_v);
  CAMLlocal1(sohm_v);
  H5F_info_t info;
  info.super_ext_size = Int_val(Field(info_v, 0));
  sohm_v = Field(info_v, 1);
  info.sohm.hdr_size = Int_val(Field(sohm_v, 0));
  info.sohm.msgs_info = H5_ih_info_val(Field(sohm_v, 1));
  CAMLreturnT(H5F_info_t, info);
}

value Val_h5f_info(H5F_info_t *info)
{
  CAMLparam0();
  CAMLlocal2(info_v, sohm_v);
  info_v = caml_alloc_tuple(2);
  Store_field(info_v, 0, Val_int(info->super_ext_size));
  sohm_v = caml_alloc_tuple(2);
  Store_field(info_v, 1, sohm_v);
  Store_field(sohm_v, 0, Val_int(info->sohm.hdr_size));
  Store_field(sohm_v, 1, Val_h5_ih_info(info->sohm.msgs_info));
  CAMLreturn(info_v);
}

H5F_mem_t H5F_mem_val(value v)
{
  switch (Int_val(v))
  {
    case 0: return H5FD_MEM_DEFAULT;
    case 1: return H5FD_MEM_SUPER;
    case 2: return H5FD_MEM_BTREE;
    case 3: return H5FD_MEM_DRAW;
    case 4: return H5FD_MEM_GHEAP;
    case 5: return H5FD_MEM_LHEAP;
    case 6: return H5FD_MEM_OHDR;
    case 7: return H5FD_MEM_NTYPES;
    default: caml_failwith("unrecognized H5F_mem_t");
  }
}

H5F_libver_t H5F_libver_val(value v)
{
  switch (Int_val(v))
  {
    case 0: return H5F_LIBVER_EARLIEST;
    case 1: return H5F_LIBVER_LATEST;
    default: caml_failwith("unrecognized H5F_libver_t");
  }
}

value hdf5_h5f_create(value name_v, value fcpl_v, value fapl_v, value flags_v)
{
  CAMLparam4(name_v, fcpl_v, fapl_v, flags_v);
  CAMLreturn(alloc_h5f(H5Fcreate(String_val(name_v), acc_val(flags_v),
    H5P_opt_val(fcpl_v), H5P_opt_val(fapl_v))));
}

value hdf5_h5f_open(value name_v, value fapl_v, value flags_v)
{
  CAMLparam3(name_v, fapl_v, flags_v);
  CAMLreturn(alloc_h5f(H5Fopen(String_val(name_v), acc_val(flags_v),
    H5P_opt_val(fapl_v))));
}

void hdf5_h5f_close(value file_v)
{
  CAMLparam1(file_v);
  raise_if_fail(H5Fclose(H5F_val(file_v)));
  H5F_closed(file_v) = true;
  CAMLreturn0;
}

void hdf5_h5f_flush(value object_v, value scope_v)
{
  CAMLparam2(object_v, scope_v);
  raise_if_fail(H5Fflush(Hid_val(object_v), H5F_scope_val(scope_v)));
  CAMLreturn0;
}

value hdf5_h5f_get_name(value obj_v)
{
  CAMLparam1(obj_v);
  CAMLlocal1(name_v);
  hid_t obj_id = Hid_val(obj_v);
  char *name;
  ssize_t size;
  size = H5Fget_name(obj_id, NULL, 0);
  if (size < 0)
    fail();
  size++;
  name = malloc(size);
  if (name == NULL)
    caml_raise_out_of_memory();
  raise_if_fail(H5Fget_name(obj_id, name, size));
  name_v = caml_copy_string(name);
  free(name);
  CAMLreturn(name_v);
}

value hdf5_h5f_get_obj_count(value file_v, value types_v)
{
  CAMLparam2(file_v, types_v);
  CAMLreturn(Val_ssize(H5Fget_obj_count(Hid_val(file_v), obj_val(types_v))));
}

value hdf5_h5f_get_obj_ids(value file_v, value types_v)
{
  CAMLparam2(file_v, types_v);
  CAMLlocal1(obj_v_list);
  hid_t file_id = Hid_val(file_v);
  unsigned int types = obj_val(types_v);
  ssize_t max_objs = H5Fget_obj_count(file_id, types), ret;
  hid_t *obj_id_list;
  raise_if_fail(max_objs);
  obj_id_list = (hid_t*) calloc(max_objs, sizeof(hid_t));
  if (obj_id_list == NULL)
    caml_raise_out_of_memory();
  ret = H5Fget_obj_ids(file_id, types, max_objs, obj_id_list);
  if (ret < 0)
  {
    free(obj_id_list);
    fail();
  }
  obj_v_list = val_hid_array(max_objs, obj_id_list);
  free(obj_id_list);
  CAMLreturn(obj_v_list);
}
