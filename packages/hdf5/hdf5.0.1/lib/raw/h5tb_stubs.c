#include <assert.h>
#include <caml/alloc.h>
#include <caml/bigarray.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include "hdf5.h"
#include "hdf5_hl.h"
#include "hdf5_caml.h"

void hdf5_h5tb_make_table(value table_title_v, value loc_v, value dset_name_v,
  value nrecords_v, value type_size_v, value field_names_v, value field_offset_v,
  value field_types_v, value chunk_size_v, value fill_data_v, value compress_v,
  value data_v)
{
  CAMLparam5(table_title_v, loc_v, dset_name_v, nrecords_v, type_size_v);
  CAMLxparam5(field_names_v, field_offset_v, field_types_v, chunk_size_v, fill_data_v);
  CAMLxparam2(compress_v, data_v);
  hsize_t nfields;
  char **field_names;
  size_t *field_offset, i;
  hid_t *field_types;
  void *fill_data, *data;
  herr_t err;

  nfields = string_array_val(field_names_v, &field_names);
  if (field_names == NULL)
    caml_raise_out_of_memory();
  if (nfields != size_t_array_val(field_offset_v, &field_offset) || field_offset == NULL)
  {
    for (i = 0; i < nfields; i++)
      free(field_names[i]);
    free(field_names);
    if (field_offset == NULL)
      caml_raise_out_of_memory();
    else
    {
      free(field_offset);
      caml_invalid_argument(
        "H5tb.make_table: field_names and field_offset not of equal lengths");
    }
  }
  if (nfields != hid_array_val(field_types_v, &field_types) || field_types == NULL)
  {
    for (i = 0; i < nfields; i++)
      free(field_names[i]);
    free(field_names);
    free(field_offset);
    if (field_types == NULL)
      caml_raise_out_of_memory();
    else
    {
      free(field_types);
      caml_invalid_argument(
        "H5tb.make_table: field_names and field_types not of equal lengths");
    }
  }
  if (fill_data_v == Val_unit)
    fill_data = NULL;
  else
  {
    fill_data_v = Field(fill_data_v, 0);
    if (Is_long(fill_data_v))
      caml_invalid_argument("H5tb.make_table: immediate values not allowed");
    else if (Tag_hd(Hd_val(fill_data_v)) == Custom_tag &&
        Custom_ops_val(fill_data_v) == caml_ba_ops)
      fill_data = Caml_ba_data_val(fill_data_v);
    else
      fill_data = (void*) fill_data_v;
  }
  if (Is_long(data_v))
    data = NULL;
  else if (Tag_hd(Hd_val(data_v)) == Custom_tag && Custom_ops_val(data_v) == caml_ba_ops)
    data = Caml_ba_data_val(data_v);
  else
    data = (void*) data_v;

  err = H5TBmake_table(String_val(table_title_v), Hid_val(loc_v), String_val(dset_name_v),
    nfields, Int_val(nrecords_v), Int_val(type_size_v), (const char**) field_names,
    field_offset, field_types, Int_val(chunk_size_v), fill_data, Int_val(compress_v),
    data);
  for (i = 0; i < nfields; i++)
    free(field_names[i]);
  free(field_names);
  free(field_offset);
  free(field_types);
  raise_if_fail(err);

  CAMLreturn0;
}

void hdf5_h5tb_make_table_bytecode(value *argv, int argn)
{
  assert(argn == 12);
  hdf5_h5tb_make_table(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5],
    argv[6], argv[7], argv[8], argv[9], argv[10], argv[11]);
}

void hdf5_h5tb_append_records(value loc_v, value dset_name_v, value nrecords_v,
  value type_size_v, value field_offset_v, value field_sizes_v, value data_v)
{
  CAMLparam5(loc_v, dset_name_v, nrecords_v, type_size_v, field_offset_v);
  CAMLxparam2(field_sizes_v, data_v);
  hid_t loc_id;
  const char *dset_name;
  hsize_t nfields, nrecords;
  size_t *field_offset, *field_sizes;
  void *data;
  herr_t err;

  loc_id = Hid_val(loc_v);
  dset_name = String_val(dset_name_v);
  raise_if_fail(H5TBget_table_info(loc_id, dset_name, &nfields, &nrecords));
  if (nfields != size_t_array_val(field_offset_v, &field_offset))
  {
    free(field_offset);
    caml_invalid_argument(
      "H5tb.append_records: the length of field_offset not equal to the number of fields"
    );
  }
  if (field_offset == NULL)
    caml_raise_out_of_memory();
  if (nfields != size_t_array_val(field_sizes_v, &field_sizes))
  {
    free(field_offset);
    free(field_sizes);
    caml_invalid_argument(
      "H5tb.append_records: the length of field_sizes not equal to the number of fields");
  }
  if (field_sizes == NULL)
  {
    free(field_offset);
    caml_raise_out_of_memory();
  }
  if (Is_long(data_v))
    caml_invalid_argument("H5tb.append_records: immediate values not allowed");
  else if (Tag_hd(Hd_val(data_v)) == Custom_tag && Custom_ops_val(data_v) == caml_ba_ops)
    data = Caml_ba_data_val(data_v);
  else
    data = (void*) data_v;

  err = H5TBappend_records(loc_id, dset_name, Int_val(nrecords_v), Int_val(type_size_v),
    field_offset, field_sizes, data);
  free(field_offset);
  free(field_sizes);
  raise_if_fail(err);
  
  CAMLreturn0;
}

void hdf5_h5tb_append_records_bytecode(value *argv, int argn)
{
  assert(argn == 7);
  hdf5_h5tb_append_records(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6]);
}

void hdf5_h5tb_write_records(value loc_v, value table_name_v, value start_v,
  value nrecords_v, value type_size_v, value field_offset_v, value field_sizes_v,
  value data_v)
{
  CAMLparam5(loc_v, table_name_v, start_v, nrecords_v, type_size_v);
  CAMLxparam3(field_offset_v, field_sizes_v, data_v);
  hid_t loc_id;
  const char *table_name;
  hsize_t nfields, nrecords;
  size_t *field_offset, *field_sizes;
  void *data;
  herr_t err;

  loc_id = Hid_val(loc_v);
  table_name = String_val(table_name_v);
  raise_if_fail(H5TBget_table_info(loc_id, table_name, &nfields, &nrecords));
  if (nfields != size_t_array_val(field_offset_v, &field_offset))
  {
    free(field_offset);
    caml_invalid_argument(
      "H5tb.write_records: the length of field_offset not equal to the number of fields"
    );
  }
  if (field_offset == NULL)
    caml_raise_out_of_memory();
  if (nfields != size_t_array_val(field_sizes_v, &field_sizes))
  {
    free(field_offset);
    free(field_sizes);
    caml_invalid_argument(
      "H5tb.write_records: the length of field_sizes not equal to the number of fields");
  }
  if (field_sizes == NULL)
  {
    free(field_offset);
    caml_raise_out_of_memory();
  }
  if (Is_long(data_v))
    caml_invalid_argument("H5tb.write_records: immediate values not allowed");
  else if (Tag_hd(Hd_val(data_v)) == Custom_tag && Custom_ops_val(data_v) == caml_ba_ops)
    data = Caml_ba_data_val(data_v);
  else
    data = (void*) data_v;

  err = H5TBwrite_records(loc_id, table_name, Int_val(start_v), Int_val(nrecords_v),
    Int_val(type_size_v), field_offset, field_sizes, data);
  free(field_offset);
  free(field_sizes);
  raise_if_fail(err);
  
  CAMLreturn0;
}

void hdf5_h5tb_write_records_bytecode(value *argv, int argn)
{
  assert(argn == 8);
  hdf5_h5tb_write_records(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6],
    argv[7]);
}

void hdf5_h5tb_read_table(value loc_v, value table_name_v, value dst_size_v,
  value dst_offset_v, value dst_sizes_v, value dst_buf_v)
{
  CAMLparam5(loc_v, table_name_v, dst_size_v, dst_offset_v, dst_sizes_v);
  CAMLxparam1(dst_buf_v);
  hid_t loc_id;
  const char *table_name;
  hsize_t nfields, nrecords;
  size_t *dst_offset, *dst_sizes;
  void *dst_buf;
  herr_t err;

  loc_id = Hid_val(loc_v);
  table_name = String_val(table_name_v);
  raise_if_fail(H5TBget_table_info(loc_id, table_name, &nfields, &nrecords));
  if (nfields != size_t_array_val(dst_offset_v, &dst_offset))
  {
    free(dst_offset);
    caml_invalid_argument(
      "H5tb.read_table: the length of dst_offset not equal to the number of fields");
  }
  if (dst_offset == NULL)
    caml_raise_out_of_memory();
  if (nfields != size_t_array_val(dst_sizes_v, &dst_sizes))
  {
    free(dst_offset);
    free(dst_sizes);
    caml_invalid_argument(
      "H5tb.read_table: the length of dst_sizes not equal to the number of fields");
  }
  if (dst_sizes == NULL)
  {
    free(dst_offset);
    caml_raise_out_of_memory();
  }
  if (Is_long(dst_buf_v))
  {
    free(dst_offset);
    free(dst_sizes);
    caml_invalid_argument("H5tb.read_table: immediate values not allowed");
  }
  else if (Tag_hd(Hd_val(dst_buf_v)) == Custom_tag
      && Custom_ops_val(dst_buf_v) == caml_ba_ops)
    dst_buf = Caml_ba_data_val(dst_buf_v);
  else
    dst_buf = (void*) dst_buf_v;

  err = H5TBread_table(loc_id, table_name, Int_val(dst_size_v), dst_offset, dst_sizes,
    dst_buf);
  free(dst_offset);
  free(dst_sizes);
  raise_if_fail(err);

  CAMLreturn0;
}

void hdf5_h5tb_read_table_bytecode(value *argv, int argn)
{
  assert(argn == 6);
  hdf5_h5tb_read_table(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}

void hdf5_h5tb_read_records(value loc_v, value table_name_v, value start_v,
  value nrecords_v, value type_size_v, value field_offset_v, value dst_sizes_v,
  value data_v)
{
  CAMLparam5(loc_v, table_name_v, start_v, nrecords_v, type_size_v);
  CAMLxparam3(field_offset_v, dst_sizes_v, data_v);
  hid_t loc_id;
  const char *table_name;
  hsize_t nfields, nrecords;
  size_t *field_offset, *dst_sizes;
  void *data;
  herr_t err;
  
  loc_id = Hid_val(loc_v);
  table_name = String_val(table_name_v);
  raise_if_fail(H5TBget_table_info(loc_id, table_name, &nfields, &nrecords));
  if (nfields != size_t_array_val(field_offset_v, &field_offset))
  {
    free(field_offset);
    caml_invalid_argument(
      "H5tb.read_records: the length of field_offset not equal to the number of fields");
  }
  if (field_offset == NULL)
    caml_raise_out_of_memory();
  if (nfields != size_t_array_val(dst_sizes_v, &dst_sizes))
  {
    free(field_offset);
    free(dst_sizes);
    caml_invalid_argument(
      "H5tb.read_records: the length of dst_sizes not equal to the number of fields");
  }
  if (dst_sizes == NULL)
  {
    free(field_offset);
    caml_raise_out_of_memory();
  }
  if (Is_long(data_v))
  {
    free(field_offset);
    free(dst_sizes);
    caml_invalid_argument("H5tb.read_records: immediate values not allowed");
  }
  else if (Tag_hd(Hd_val(data_v)) == Custom_tag && Custom_ops_val(data_v) == caml_ba_ops)
    data = Caml_ba_data_val(data_v);
  else
    data = (void*) data_v;

  err = H5TBread_records(loc_id, table_name, Int_val(start_v), Int_val(nrecords_v),
    Int_val(type_size_v), field_offset, dst_sizes, data);
  free(field_offset);
  free(dst_sizes);
  raise_if_fail(err);
  CAMLreturn0;
}

void hdf5_h5tb_read_records_bytecode(value *argv, int argn)
{
  assert(argn == 8);
  hdf5_h5tb_read_records(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6],
    argv[7]);
}

value hdf5_h5tb_get_table_info(value loc_v, value table_name_v)
{
  CAMLparam2(loc_v, table_name_v);
  hsize_t nfields, nrecords;
  raise_if_fail(H5TBget_table_info(Hid_val(loc_v), String_val(table_name_v), &nfields,
    &nrecords));
  CAMLreturn(Val_int(nrecords));
}

value hdf5_h5tb_get_field_info(value loc_v, value table_name_v)
{
  CAMLparam2(loc_v, table_name_v);
  CAMLlocal1(field_info_v);
  hid_t loc_id;
  const char *table_name;
  hsize_t nfields, nrecords;
  char **field_names;
  size_t *field_sizes, *field_offsets, type_size, i, j;
  herr_t err;

  loc_id = Hid_val(loc_v);
  table_name = String_val(table_name_v);
  raise_if_fail(H5TBget_table_info(loc_id, table_name, &nfields, &nrecords));
  field_names = calloc(nfields, sizeof(char*));
  if (field_names == NULL)
    caml_raise_out_of_memory();
  for (i = 0; i < nfields; i++)
  {
    field_names[i] = calloc(255, sizeof(char*));
    if (field_names[i] == NULL)
    {
      for (j = 0; j < i; j++)
        free(field_names[j]);
      free(field_names);
      caml_raise_out_of_memory();
    }
  }
  field_sizes = calloc(nfields, sizeof(size_t));
  if (field_sizes == NULL)
  {
    free(field_names);
    caml_raise_out_of_memory();
  }
  field_offsets = calloc(nfields, sizeof(size_t));
  if (field_offsets == NULL)
  {
    free(field_names);
    free(field_sizes);
    caml_raise_out_of_memory();
  }
  err = H5TBget_field_info(loc_id, table_name, field_names, field_sizes, field_offsets,
    &type_size);
  if (err == -1)
  {
    free(field_names);
    free(field_sizes);
    free(field_offsets);
    fail();
  }
  field_info_v = caml_alloc_tuple(4);
  Store_field(field_info_v, 0, val_string_array(nfields, (const char**) field_names));
  for (i = 0; i < nfields; i++)
    free(field_names[i]);
  free(field_names);
  Store_field(field_info_v, 1, val_size_t_array(nfields, field_sizes));
  free(field_sizes);
  Store_field(field_info_v, 2, val_size_t_array(nfields, field_offsets));
  free(field_offsets);
  Store_field(field_info_v, 3, Val_int(type_size));
  CAMLreturn(field_info_v);
}
