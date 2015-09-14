module Storage_type = struct
  type t =
  | SYMBOL_TABLE
  | COMPACT
  | DENSE
end

module Info = struct
  type t = {
    storage_type : Storage_type.t;
    nlinks       : int;
    max_corder   : int;
    mounted      : bool;
  }
end

module Iterate = struct
  type h5g =Hid.t
  type 'a t = h5g -> string -> 'a -> H5.Iter.t
end

external close : Hid.t -> unit = "hdf5_h5g_close"
external create : Hid.t -> ?lcpl:Hid.t -> ?gcpl:Hid.t -> ?gapl:Hid.t -> string -> Hid.t
  = "hdf5_h5g_create"
external open_ : Hid.t -> ?gapl:Hid.t -> string -> Hid.t = "hdf5_h5g_open"
external link : Hid.t -> H5l.Type.t -> current_name:string -> new_name:string -> unit
  = "hdf5_h5g_link"
external unlink : Hid.t -> string -> unit = "hdf5_h5g_unlink"
external set_comment : Hid.t -> string -> string -> unit = "hdf5_h5g_set_comment"
external get_comment : Hid.t -> string -> string = "hdf5_h5g_get_comment"
external get_info : Hid.t -> Info.t = "hdf5_h5g_get_info"
external iterate : Hid.t -> string -> ?idx:int ref -> 'a Iterate.t -> 'a -> H5.Iter.t
  = "hdf5_h5g_iterate"
