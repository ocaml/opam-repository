#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include "hdf5.h"
#include "hdf5_caml.h"

void fail()
{
  caml_raise_constant(*caml_named_value("HDF5.H5I.Fail"));
}

void raise_if_fail(hid_t id)
{
  if (id == -1)
    fail();
}

H5I_type_t H5I_type_val(value v)
{
  switch (Int_val(v))
  {
    case  0: return H5I_FILE;
    case  1: return H5I_GROUP;
    case  2: return H5I_DATATYPE;
    case  3: return H5I_DATASPACE;
    case  4: return H5I_DATASET;
    case  5: return H5I_ATTR;
    case  6: return H5I_REFERENCE;
    case  7: return H5I_VFL;
    case  8: return H5I_GENPROP_CLS;
    case  9: return H5I_GENPROP_LST;
    case 10: return H5I_ERROR_CLASS;
    case 11: return H5I_ERROR_MSG;
    case 12: return H5I_ERROR_STACK;
    case 13: return H5I_NTYPES;
    default: caml_failwith("unrecognized H5I_type_t");
  }
}

value Val_h5i_type(H5I_type_t v)
{
  switch (v)
  {
    case H5I_UNINIT      : fail();
    case H5I_BADID       : fail();
    case H5I_FILE        : return Val_int( 0);
    case H5I_GROUP       : return Val_int( 1);
    case H5I_DATATYPE    : return Val_int( 2);
    case H5I_DATASPACE   : return Val_int( 3);
    case H5I_DATASET     : return Val_int( 4);
    case H5I_ATTR        : return Val_int( 5);
    case H5I_REFERENCE   : return Val_int( 6);
    case H5I_VFL         : return Val_int( 7);
    case H5I_GENPROP_CLS : return Val_int( 8);
    case H5I_GENPROP_LST : return Val_int( 9);
    case H5I_ERROR_CLASS : return Val_int(10);
    case H5I_ERROR_MSG   : return Val_int(11);
    case H5I_ERROR_STACK : return Val_int(12);
    case H5I_NTYPES      : return Val_int(13);
    default: caml_failwith("unrecognized H5I_type_t");
  }
}

value hdf5_h5i_get_type(value obj_v)
{
  CAMLparam1(obj_v);
  CAMLreturn(Val_h5i_type(H5Iget_type(Hid_val(obj_v))));
}
