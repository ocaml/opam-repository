module Cls_id : sig
  type t =
  | OBJECT_CREATE
  | FILE_CREATE
  | FILE_ACCESS
  | DATASET_CREATE
  | DATASET_ACCESS
  | DATASET_XFER
  | FILE_MOUNT
  | GROUP_CREATE
  | GROUP_ACCESS
  | DATATYPE_CREATE
  | DATATYPE_ACCESS
  | STRING_CREATE
  | ATTRIBUTE_CREATE
  | OBJECT_COPY
  | LINK_CREATE
  | LINK_ACCESS
end

module Alloc : sig
  type 'a t = int -> 'a
end

module Free : sig
  type 'a t = 'a -> unit
end

external create : Cls_id.t -> Hid.t = "hdf5_h5p_create"
external close : Hid.t -> unit = "hdf5_h5p_close"
external set_userblock : Hid.t -> int -> unit = "hdf5_h5p_set_userblock"
external set_create_intermediate_group : Hid.t -> bool -> unit
  = "hdf5_h5p_set_create_intermediate_group"
external get_create_intermediate_group : Hid.t -> bool
  = "hdf5_h5p_get_create_intermediate_group"
external get_layout : Hid.t -> Layout.t = "hdf5_h5p_get_layout"
external set_chunk : Hid.t -> Hsize.t array -> unit = "hdf5_h5p_set_chunk"
external get_chunk : Hid.t -> Hsize.t array = "hdf5_h5p_get_chunk"
external set_deflate : Hid.t -> int -> unit = "hdf5_h5p_set_deflate"
external set_filter : Hid.t -> H5z.Filter.t -> H5z.Flag.t list -> int array -> unit
  = "hdf5_h5p_set_filter"
external set_fletcher32 : Hid.t -> unit = "hdf5_h5p_set_fletcher32"
external set_nbit : Hid.t -> unit = "hdf5_h5p_set_nbit"
external set_shuffle : Hid.t -> unit = "hdf5_h5p_set_shuffle"
external set_vlen_mem_manager : Hid.t -> 'a Alloc.t -> 'a Free.t -> unit
  = "hdf5_h5p_set_vlen_mem_manager"
external get_vlen_mem_manager : Hid.t -> ('a Alloc.t * 'a Free.t)
  = "hdf5_h5p_set_vlen_mem_manager"
