#include <assert.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include "hdf5.h"
#include "hdf5_caml.h"

void h5s_finalize(value v)
{
  if (!Hid_closed(v))
    H5Sclose(Hid_val(v));
  Hid_closed(v) = true;
}

static struct custom_operations h5s_ops = {
  "hdf5.h5s",
  h5s_finalize,
  custom_compare_default,
  custom_compare_ext_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default
};

value alloc_h5s(hid_t id)
{
  value v;
  raise_if_fail(id);
  v = caml_alloc_custom(&h5s_ops, sizeof(hid_t) + sizeof(bool), 0, 1);
  Hid_val(v) = id;
  Hid_closed(v) = false;
  return v;
}

H5S_class_t H5S_class_val(value class)
{
  switch (Int_val(class))
  {
    case 0: return H5S_SCALAR;
    case 1: return H5S_SIMPLE;
    case 2: return H5S_NULL;
    default: caml_failwith("unrecognized H5S_class_t");
  }
}

value Val_h5s_class(H5S_class_t class)
{
  switch (class)
  {
    case H5S_NO_CLASS: fail();
    case H5S_SCALAR:   return Val_int(0);
    case H5S_SIMPLE:   return Val_int(1);
    case H5S_NULL:     return Val_int(2);
    default: caml_failwith("unrecognized H5S_class_t");
  }
}

H5S_seloper_t H5S_seloper_val(value class)
{
  switch (Int_val(class))
  {
    case 0: return H5S_SELECT_SET;
    case 1: return H5S_SELECT_OR;
    case 2: return H5S_SELECT_AND;
    case 3: return H5S_SELECT_XOR;
    case 4: return H5S_SELECT_NOTB;
    case 5: return H5S_SELECT_NOTA;
    default: caml_failwith("unrecognized H5S_seloper_t");
  }
}

value hdf5_h5s_get_all()
{
  CAMLparam0();
  CAMLreturn(alloc_h5s(H5S_ALL));
}

value hdf5_h5s_create(value type_v)
{
  CAMLparam1(type_v);
  CAMLreturn(alloc_h5s(H5Screate(H5S_class_val(type_v))));
}

void hdf5_h5s_close(value space_v)
{
  CAMLparam1(space_v);
  raise_if_fail(H5Sclose(Hid_val(space_v)));
  Hid_closed(space_v) = true;
  CAMLreturn0;
}

value hdf5_h5s_create_simple(value maximum_dims_v, value current_dims_v)
{
  CAMLparam2(maximum_dims_v, current_dims_v);
  int rank, maximum_dims_length;
  hsize_t *current_dims, *maximum_dims;
  hid_t id;

  rank = hsize_t_array_val(current_dims_v, &current_dims);
  if (current_dims == NULL)
    caml_raise_out_of_memory();
  maximum_dims_length = hsize_t_array_opt_val(maximum_dims_v, &maximum_dims);
  if (maximum_dims != NULL && rank != maximum_dims_length)
  {
    free(current_dims);
    free(maximum_dims);
    caml_invalid_argument(
      "H5s.create_simple: current_dims and maximum_dims not of same length");
  }
  if (maximum_dims == NULL && maximum_dims_length != 0)
  {
    free(current_dims);
    caml_raise_out_of_memory();
  }
  id = H5Screate_simple(rank, current_dims, maximum_dims);
  free(current_dims);
  free(maximum_dims);

  CAMLreturn(alloc_h5s(id));
}

value hdf5_h5s_get_simple_extent_dims(value space_id_v)
{
  CAMLparam1(space_id_v);

  CAMLlocal3(dims_v, maxdims_v, ret);
  hid_t space_id = Hid_val(space_id_v);
  hsize_t *dims, *maxdims;

  int ndims = H5Sget_simple_extent_ndims(space_id);
  if (ndims < 0)
    fail();
  dims = calloc(ndims, sizeof(hsize_t));
  if (dims == NULL)
    caml_raise_out_of_memory();
  maxdims = calloc(ndims, sizeof(hsize_t));
  if (maxdims == NULL)
  {
    free(dims);
    caml_raise_out_of_memory();
  }
  if (ndims != H5Sget_simple_extent_dims(space_id, dims, maxdims))
  {
    free(dims);
    free(maxdims);
    fail();
  }
  dims_v = val_hsize_t_array(ndims, dims);
  maxdims_v = val_hsize_t_array(ndims, maxdims);
  ret = caml_alloc_tuple(2);
  Store_field(ret, 0, dims_v);
  Store_field(ret, 1, maxdims_v);
  CAMLreturn(ret);
}

value hdf5_h5s_get_simple_extent_npoints(value space_id_v)
{
  CAMLparam1(space_id_v);
  CAMLreturn(Val_int(H5Sget_simple_extent_npoints(Hid_val(space_id_v))));
}

value hdf5_h5s_get_simple_extent_type(value space_id_v)
{
  CAMLparam1(space_id_v);
  CAMLreturn(Val_h5s_class(H5Sget_simple_extent_type(Hid_val(space_id_v))));
}

void hdf5_h5s_set_extent_simple(value space_id_v, value maximum_size_v,
  value current_size_v)
{
  CAMLparam3(space_id_v, maximum_size_v, current_size_v);
  int rank, maximum_size_length;
  hsize_t *current_size, *maximum_size;
  herr_t err;

  rank = hsize_t_array_val(current_size_v, &current_size);
  if (current_size == NULL)
    caml_raise_out_of_memory();
  maximum_size_length = hsize_t_array_opt_val(maximum_size_v, &maximum_size);
  if (maximum_size != NULL && rank != maximum_size_length)
  {
    free(current_size);
    free(maximum_size);
    caml_invalid_argument(
      "H5s.set_extent_simple: current_size and maximum_size not of same length");
  }
  if (maximum_size == NULL && maximum_size_length != 0)
  {
    free(current_size);
    caml_raise_out_of_memory();
  }
  err = H5Sset_extent_simple(Hid_val(space_id_v), rank, current_size, maximum_size);
  free(current_size);
  free(maximum_size);
  raise_if_fail(err);
  CAMLreturn0;
}

value hdf5_h5s_get_select_npoints(value space_id_v)
{
  CAMLparam1(space_id_v);
  hssize_t v = H5Sget_select_npoints(Hid_val(space_id_v));
  if (v < 0) fail();
  CAMLreturn(Val_int(v));
}

value hdf5_h5s_get_select_hyper_blocklist(value startblock_opt_v, value numblocks_opt_v,
  value space_id_v)
{
  CAMLparam3(startblock_opt_v, numblocks_opt_v, space_id_v);
  CAMLlocal1(v);
  hsize_t startblock = Int_opt_val(startblock_opt_v, 0), numblocks, *buf;
  hssize_t nblocks;
  herr_t err;
  hid_t space_id = Hid_val(space_id_v);
  int ndims = H5Sget_simple_extent_ndims(space_id);
  if (Is_block(numblocks_opt_v))
    numblocks = Int_val(Field(numblocks_opt_v, 0));
  else
  {
    nblocks = H5Sget_select_hyper_nblocks(space_id);
    if (nblocks < 0) fail();
    numblocks = nblocks - startblock;
  }
  buf = calloc(numblocks * 2 * ndims, sizeof(hsize_t));
  if (buf == NULL)
    caml_raise_out_of_memory();
  err = H5Sget_select_hyper_blocklist(space_id, startblock, numblocks, buf);
  if (err < 0)
  {
    free(buf);
    fail();
  }
  v = val_hsize_t_array(numblocks * 2 * ndims, buf);
  free(buf);
  CAMLreturn(v);
}

value hdf5_h5s_get_select_elem_pointlist(value startblock_opt_v, value numpoints_opt_v,
  value space_id_v)
{
  CAMLparam3(startblock_opt_v, numpoints_opt_v, space_id_v);
  CAMLlocal1(v);
  hsize_t startblock = Int_opt_val(startblock_opt_v, 0), numpoints, *buf;
  hssize_t npoints;
  herr_t err;
  hid_t space_id = Hid_val(space_id_v);
  int ndims = H5Sget_simple_extent_ndims(space_id);
  if (Is_block(numpoints_opt_v))
    numpoints = Int_val(Field(numpoints_opt_v, 0));
  else
  {
    npoints = H5Sget_select_elem_npoints(space_id);
    if (npoints < 0) fail();
    numpoints = npoints - startblock;
  }
  buf = calloc(numpoints * 2 * ndims, sizeof(hsize_t));
  if (buf == NULL)
    caml_raise_out_of_memory();
  err = H5Sget_select_elem_pointlist(space_id, startblock, numpoints, buf);
  if (err < 0)
  {
    free(buf);
    fail();
  }
  v = val_hsize_t_array(numpoints * 2 * ndims, buf);
  free(buf);
  CAMLreturn(v);
}

value hdf5_h5s_get_select_bounds(value space_id_v)
{
  CAMLparam1(space_id_v);
  CAMLlocal1(v);
  hsize_t start, end;
  raise_if_fail(H5Sget_select_bounds(Hid_val(space_id_v), &start, &end));
  v = caml_alloc_tuple(2);
  Store_field(v, 0, Val_int(start));
  Store_field(v, 1, Val_int(end));
  CAMLreturn(v);
}

void hdf5_h5s_select_elements(value space_id_v, value op_v, value coord_v)
{
  CAMLparam3(space_id_v, op_v, coord_v);

  hid_t space_id = Hid_val(space_id_v);
  int ndims, coord_len;
  size_t num_elements;
  hsize_t *coord;
  herr_t err;

  ndims = H5Sget_simple_extent_ndims(space_id);
  coord_len = hsize_t_array_val(coord_v, &coord);
  num_elements = coord_len / ndims;
  if (num_elements * ndims != (size_t) coord_len)
  {
    free(coord);
    caml_invalid_argument(
      "H5s.select_elements: The number of coordinates not a multiply of the number of "
      "dimensions");
  }
  err = H5Sselect_elements(space_id, H5S_seloper_val(op_v), num_elements, coord);
  free(coord);
  raise_if_fail(err);
  CAMLreturn0;
}

void hdf5_h5s_select_none(value space_id_v)
{
  CAMLparam1(space_id_v);
  raise_if_fail(H5Sselect_none(Hid_val(space_id_v)));
  CAMLreturn0;
}

void hdf5_h5s_select_hyperslab(value space_id_v, value op_v, value start_v,
  value stride_v, value count_v, value block_v, value unit_v)
{
  CAMLparam5(space_id_v, op_v, start_v, stride_v, count_v);
  CAMLxparam2(block_v, unit_v);

  hid_t space_id = Hid_val(space_id_v);
  size_t ndims;
  hsize_t *start, *stride, *count, *block;
  herr_t err;
  
  ndims = H5Sget_simple_extent_ndims(space_id);
  if (ndims != hsize_t_array_val(start_v, &start))
  {
    free(start);
    caml_invalid_argument(
      "H5s.select_hyperslab: start not the size as the rank of the dataspace");
  }
  if (ndims != hsize_t_array_opt_val(stride_v, &stride) && stride != NULL)
  {
    free(start);
    free(stride);
    caml_invalid_argument(
      "H5s.select_hyperslab: stride not the size as the rank of the dataspace");
  }
  if (ndims != hsize_t_array_val(count_v, &count))
  {
    free(start);
    free(stride);
    free(count);
    caml_invalid_argument(
      "H5s.select_hyperslab: count not the size as the rank of the dataspace");
  }
  if (ndims != hsize_t_array_opt_val(block_v, &block) && block != NULL)
  {
    free(start);
    free(stride);
    free(count);
    free(block);
    caml_invalid_argument(
      "H5s.select_hyperslab: block not the size as the rank of the dataspace");
  }
  err = H5Sselect_hyperslab(space_id, H5S_seloper_val(op_v), start, stride, count,
    block);
  free(start);
  free(stride);
  free(count);
  free(block);
  raise_if_fail(err);
  CAMLreturn0;
}

void hdf5_h5s_select_hyperslab_bytecode(value *argv, int argn)
{
  assert(argn == 7);
  hdf5_h5s_select_hyperslab(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5],
    argv[6]);
}
