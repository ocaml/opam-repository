#include <assert.h>
#include <caml/alloc.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include "hdf5.h"
#include "hdf5_caml.h"

H5Z_filter_t H5Z_filter_val(value v)
{
  if (Is_block(v))
  {
    switch (Tag_val(v))
    {
      case 0: return (H5Z_filter_t) Int_val(Field(v, 0));
      default: caml_failwith("unrecognized H5Z_filter_t");
    }
  }
  else
    switch (Int_val(v))
    {
      case 0: return H5Z_FILTER_NONE       ;
      case 1: return H5Z_FILTER_DEFLATE    ;
      case 2: return H5Z_FILTER_SHUFFLE    ;
      case 3: return H5Z_FILTER_FLETCHER32 ;
      case 4: return H5Z_FILTER_SZIP       ;
      case 5: return H5Z_FILTER_NBIT       ;
      case 6: return H5Z_FILTER_SCALEOFFSET;
      default: caml_failwith("unrecognized H5Z_FILTER_filter_t");
    }
}

value Val_h5z_filter(H5Z_filter_t f)
{
  value v;
  switch (f)
  {
    case H5Z_FILTER_NONE       : return Val_int(0);
    case H5Z_FILTER_DEFLATE    : return Val_int(1);
    case H5Z_FILTER_SHUFFLE    : return Val_int(2);
    case H5Z_FILTER_FLETCHER32 : return Val_int(3);
    case H5Z_FILTER_SZIP       : return Val_int(4);
    case H5Z_FILTER_NBIT       : return Val_int(5);
    case H5Z_FILTER_SCALEOFFSET: return Val_int(6);
    default:
      v = caml_alloc(1, 0);
      Field(v, 0) = Val_int((int) f);
      return v;
  }
}

unsigned flag_val(value v)
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
      case 0: flags |= H5Z_FLAG_DEFMASK ; break;
      case 1: flags |= H5Z_FLAG_OPTIONAL; break;
      case 2: flags |= H5Z_FLAG_REVERSE ; break;
      case 3: flags |= H5Z_FLAG_SKIP_EDC; break;
      default: caml_failwith("unrecognized flag");
    }
  }
  assert(Int_val(v) == 0);
  CAMLreturnT(unsigned, flags);
}

value val_filter_config(unsigned f)
{
  CAMLparam0();
  CAMLlocal3(h, v, t);

  h = Val_unit;
  while (f != 0)
  {
    if (f & H5Z_FILTER_CONFIG_ENCODE_ENABLED)
    {
      v = Val_int(0);
      f ^= H5Z_FILTER_CONFIG_ENCODE_ENABLED;
    }
    else if (f & H5Z_FILTER_CONFIG_DECODE_ENABLED)
    {
      v = Val_int(1);
      f ^= H5Z_FILTER_CONFIG_DECODE_ENABLED;
    }
    else caml_failwith("unrecognized filter_config");
    t = h;
    h = caml_alloc(2, 0);
    Store_field(h, 0, v);
    Store_field(h, 1, t);
  }
  CAMLreturn(h);
}

value hdf5_h5z_filter_avail(value filter_v)
{
  CAMLparam1(filter_v);
  CAMLreturn(Val_htri(H5Zfilter_avail(H5Z_filter_val(filter_v))));
}

value hdf5_h5z_get_filter_info(value filter_v)
{
  CAMLparam1(filter_v);
  unsigned int filter_config;
  raise_if_fail(H5Zget_filter_info(H5Z_filter_val(filter_v), &filter_config));
  CAMLreturn(val_filter_config(filter_config));
}
