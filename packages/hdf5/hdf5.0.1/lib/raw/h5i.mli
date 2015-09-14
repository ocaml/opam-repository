exception Fail

module Type : sig
  type t =
  | FILE
  | GROUP
  | DATATYPE
  | DATASPACE
  | DATASET
  | ATTR
  | REFERENCE
  | VFL
  | GENPROP_CLS
  | GENPROP_LST
  | ERROR_CLASS
  | ERROR_MSG
  | ERROR_STACK
  | NTYPES
end

external get_type : Hid.t -> Type.t = "hdf5_h5i_get_type"
