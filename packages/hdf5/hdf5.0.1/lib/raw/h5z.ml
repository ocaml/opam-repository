module Filter = struct
  type t =
  | NONE
  | DEFLATE
  | SHUFFLE
  | FLETCHER32
  | SZIP
  | NBIT
  | SCALEOFFSET
  | CUSTOM of int
end

module Flag = struct
  type t =
  | MANDATORY
  | OPTIONAL
  | REVERSE
  | SKIP_EDC
end

module Filter_config = struct
  type t =
  | ENCODE_ENABLED
  | DECODE_ENABLED
end

external filter_avail : Filter.t -> bool = "hdf5_h5z_filter_avail"
external get_filter_info : Filter.t -> Filter_config.t list = "hdf5_h5z_get_filter_info"
