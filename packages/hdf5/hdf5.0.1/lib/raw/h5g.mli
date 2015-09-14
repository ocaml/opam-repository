module Storage_type : sig
  type t =
  | SYMBOL_TABLE
  | COMPACT
  | DENSE
end

module Info : sig
  type t = {
    storage_type : Storage_type.t;
    nlinks       : int;
    max_corder   : int;
    mounted      : bool;
  }
end

module Iterate : sig
  type 'a t = Hid.t -> string -> 'a -> H5.Iter.t
end

external close : Hid.t -> unit = "hdf5_h5g_close"
external create : Hid.t -> ?lcpl:Hid.t -> ?gcpl:Hid.t -> ?gapl:Hid.t -> string -> Hid.t
  = "hdf5_h5g_create"
external open_ : Hid.t -> ?gapl:Hid.t -> string -> Hid.t = "hdf5_h5g_open"
external link : Hid.t -> H5l.Type.t -> current_name:string -> new_name:string -> unit
  = "hdf5_h5g_link" [@@ocaml.deprecated "Use H5l.create_hard or H5l.create_soft instead"]
external unlink : Hid.t -> string -> unit = "hdf5_h5g_unlink"
  [@@ocaml.deprecated "Use H5l.delete"]
external set_comment : Hid.t -> string -> string -> unit = "hdf5_h5g_set_comment"
  [@@ocaml.deprecated "Use H5o.set_comment"]
external get_comment : Hid.t -> string -> string = "hdf5_h5g_get_comment"
  [@@ocaml.deprecated "Use H5o.get_comment"]
external get_info : Hid.t -> Info.t = "hdf5_h5g_get_info"
external iterate : Hid.t -> string -> ?idx:int ref -> 'a Iterate.t -> 'a -> H5.Iter.t
  = "hdf5_h5g_iterate" [@@ocaml.deprecated "Use H5l.iterate instead"]
