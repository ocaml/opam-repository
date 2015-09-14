module Acc : sig
  type t =
  | RDONLY
  | RDWR
  | TRUNC
  | EXCL
  | DEBUG
  | CREAT
  | DEFAULT
end

module Obj : sig
  type t =
  | FILE
  | DATASET
  | GROUP
  | DATATYPE
  | ATTR
  | ALL
  | LOCAL
end

module Scope : sig
  type t =
  | LOCAL
  | GLOBAL
end

module Close_degree : sig
  type t =
  | DEFAULT
  | WEAK
  | SEMI
  | STRONG
end

module Info : sig
  module Sohm : sig
    type t = {
      hdr_size  : Hsize.t;
      msgs_info : H5.Ih_info.t
    }
  end

  type t = {
    super_ext_size : Hsize.t;
    sohm           : Sohm.t;
  }
end

module Mem : sig
  type t =
  | DEFAULT
  | SUPER
  | BTREE
  | DRAW
  | GHEAP
  | LHEAP
  | OHDR
  | NTYPES
end

module Libver : sig
  type t =
  | EARLIEST
  | LATEST
end

external create : string -> ?fcpl:Hid.t -> ?fapl:Hid.t -> Acc.t list -> Hid.t
  = "hdf5_h5f_create"
external open_ : string -> ?fapl:Hid.t -> Acc.t list -> Hid.t = "hdf5_h5f_open"
external close : Hid.t -> unit = "hdf5_h5f_close"
external flush : Hid.t -> Scope.t -> unit = "hdf5_h5f_flush"
external get_name : Hid.t -> string = "hdf5_h5f_get_name"
external get_obj_count : Hid.t -> Obj.t list -> int = "hdf5_h5f_get_obj_count"
external get_obj_ids : Hid.t -> Obj.t list -> Hid.t array = "hdf5_h5f_get_obj_ids"
