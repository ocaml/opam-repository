module Info = struct
  type t = {
    corder_valid : bool;
    corder       : H5o.Msg_crt_idx.t;
    cset         : H5t.Cset.t;
    data_size    : int }
end

module Iterate = struct
  type 'a t = Hid.t -> string -> Info.t -> 'a -> H5.Iter.t
end

external create : Hid.t -> string -> Hid.t -> ?acpl:Hid.t -> ?aapl:Hid.t -> Hid.t -> Hid.t
  = "hdf5_h5a_create_bytecode" "hdf5_h5a_create"
external create_by_name : Hid.t -> string -> string -> Hid.t -> ?acpl:Hid.t
  -> ?aapl:Hid.t -> ?lapl:Hid.t -> Hid.t -> Hid.t
  = "hdf5_h5a_create_by_name_bytecode" "hdf5_h5a_create_by_name"
external open_ : Hid.t -> ?aapl:Hid.t -> string -> Hid.t = "hdf5_h5a_open"
external open_by_name : Hid.t -> ?aapl:Hid.t -> ?lapl:Hid.t -> string -> string -> Hid.t
  = "hdf5_h5a_open_by_name"
external open_name : Hid.t -> string -> Hid.t = "hdf5_h5a_open_name"
external open_by_idx : Hid.t -> ?aapl:Hid.t -> ?lapl:Hid.t -> H5.Index.t
  -> H5.Iter_order.t -> int -> Hid.t
  = "hdf5_h5a_open_by_idx_bytecode" "hdf5_h5a_open_by_idx"
external open_idx : Hid.t -> int -> Hid.t = "hdf5_h5a_open_idx"
external exists : Hid.t -> string -> bool = "hdf5_h5a_exists"
external exists_by_name : Hid.t -> string -> ?lapl:Hid.t -> string -> bool
  = "hdf5_h5a_exists_by_name"
external rename : Hid.t -> string -> string -> unit = "hdf5_h5a_rename"
external rename_by_name : Hid.t -> string -> ?lapl:Hid.t -> string -> string -> unit
  = "hdf5_h5a_rename_by_name"
external write : Hid.t -> Hid.t -> _ -> unit = "hdf5_h5a_write"
external read : Hid.t -> Hid.t -> _ -> unit = "hdf5_h5a_read"
external read_vl : Hid.t -> Hid.t -> string array -> unit = "hdf5_h5a_read_vl"
external close : Hid.t -> unit = "hdf5_h5a_close"
external iterate : Hid.t -> ?idx_type:H5.Index.t -> ?iter_order:H5.Iter_order.t
  -> ?n:int ref -> 'a Iterate.t -> 'a -> H5.Iter.t
  = "hdf5_h5a_iterate_bytecode" "hdf5_h5a_iterate"
external iterate_by_name : Hid.t -> string -> ?idx_type:H5.Index.t
  -> ?iter_order:H5.Iter_order.t -> ?n:int ref -> ?lapd:Hid.t -> 'a Iterate.t -> 'a
  -> H5.Iter.t = "hdf5_h5a_iterate_by_name_bytecode" "hdf5_h5a_iterate_by_name"
external delete : Hid.t -> string -> unit = "hdf5_h5a_delete"
external delete_by_name : Hid.t -> ?lapl:Hid.t -> string -> string -> unit
  = "hdf5_h5a_delete_by_name"
external delete_by_idx : Hid.t -> string -> ?idx_type:H5.Index.t
  -> ?iter_order:H5.Iter_order.t -> ?lapl:Hid.t -> int -> unit
  = "hdf5_h5a_delete_by_idx_bytecode" "hdf5_h5a_delete_by_idx"
external get_info : Hid.t -> Info.t = "hdf5_h5a_get_info"
external get_info_by_name : Hid.t -> string -> ?lapl:Hid.t -> string -> Info.t
  = "hdf5_h5a_get_info_by_name"
external get_info_by_idx : Hid.t -> string -> ?idx_type:H5.Index.t
  -> ?order:H5.Iter_order.t -> ?lapl:Hid.t -> int -> Info.t
  = "hdf5_h5a_get_info_by_idx_bytecode" "hdf5_h5a_get_info_by_idx"
external get_num_attrs : Hid.t -> int = "hdf5_h5a_get_num_attrs"
external get_name : Hid.t -> string = "hdf5_h5a_get_name"
external get_create_plist : Hid.t -> Hid.t = "hdf5_h5a_get_create_plist"
external get_space : Hid.t -> Hid.t = "hdf5_h5a_get_space"
external get_type : Hid.t -> Hid.t = "hdf5_h5a_get_type"
external get_storage_size : Hid.t -> int = "hdf5_h5a_get_storage_size"
external get_name_by_idx : Hid.t -> string -> ?idx_type:H5.Index.t
  -> ?order:H5.Iter_order.t -> ?lapl:Hid.t -> int -> string
  = "hdf5_h5a_get_name_by_idx_bytecode" "hdf5_h5a_get_name_by_idx"
