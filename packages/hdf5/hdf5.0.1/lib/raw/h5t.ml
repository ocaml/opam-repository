module Class = struct
  type t =
  | NO_CLASS
  | INTEGER
  | FLOAT
  | TIME
  | STRING
  | BITFIELD
  | OPAQUE
  | COMPOUND
  | REFERENCE
  | ENUM
  | VLEN
  | ARRAY
  | NCLASSES
end

module Order = struct
  type t =
  | ERROR
  | LE
  | BE
  | VAX
  | NONE
end

module Sign = struct
  type t =
  | NONE
  | SIGN_2
  | NSGN
end

module Norm = struct
  type t =
  | IMPLIED
  | MSBSET
  | NONE
end

module Cset = struct
  type t =
  | ASCII
  | UTF8
end

module Str = struct
  type t =
  | NULLTERM
  | NULLPAD
  | SPACEPAD
end

module Pad = struct
  type t =
  | ZERO
  | ONE
  | BACKGROUND
  | NPAD
end

module Cmd = struct
  type t =
  | INIT
  | CONV
  | FREE
end

module Bkg = struct
  type t =
  | NO
  | TEMP
  | YES
end

module Cdata = struct
  type t = {
    command  : Cmd.t;
    need_bkg : Bkg.t;
    recalc   : bool;
    priv     : int64 }
end

module Pers = struct
  type t =
  | DONTCARE
  | HARD
  | SOFT
end

module Direction = struct
  type t =
  | DEFAULT
  | ASCEND
  | DESCEND
end

module Conv_except = struct
  type t =
  | RANGE_HI
  | RANGE_LOW
  | PRECISION
  | TRUNCATE
  | PINF
  | NINF
  | NAN
end

module Conv_ret = struct
  type t =
  | ABORT
  | UNHANDLED
  | HANDLED
end

external get_variable : unit -> int = "hdf5_h5t_get_variable"
let variable = get_variable ()

external datatypes : unit -> (Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t
  * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t
  * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t
  * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t
  * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t
  * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t
  * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t
  * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t
  * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t
  * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t
  * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t
  * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t * Hid.t)
  = "hdf5_h5t_datatypes"

let ieee_f32be, ieee_f32le, ieee_f64be, ieee_f64le, std_i8be, std_i8le, std_i16be,
  std_i16le, std_i32be, std_i32le, std_i64be, std_i64le, std_u8be, std_u8le, std_u16be,
  std_u16le, std_u32be, std_u32le, std_u64be, std_u64le, std_b8be, std_b8le, std_b16be,
  std_b16le, std_b32be, std_b32le, std_b64be, std_b64le, std_ref_obj, std_ref_dsetreg,
  unix_d32be, unix_d32le, unix_d64be, unix_d64le, c_s1, fortran_s1, intel_i8, intel_i16,
  intel_i32, intel_i64, intel_u8, intel_u16, intel_u32, intel_u64, intel_b8, intel_b16,
  intel_b32, intel_b64, intel_f32, intel_f64, alpha_i8, alpha_i16, alpha_i32, alpha_i64,
  alpha_u8, alpha_u16, alpha_u32, alpha_u64, alpha_b8, alpha_b16, alpha_b32, alpha_b64,
  alpha_f32, alpha_f64, mips_i8, mips_i16, mips_i32, mips_i64, mips_u8, mips_u16,
  mips_u32, mips_u64, mips_b8, mips_b16, mips_b32, mips_b64, mips_f32, mips_f64, vax_f32,
  vax_f64, native_char, native_schar, native_uchar, native_short, native_ushort,
  native_int, native_uint, native_long, native_ulong, native_llong, native_ullong,
  native_float, native_double, native_ldouble, native_b8, native_b16, native_b32,
  native_b64, native_opaque, native_haddr, native_hsize, native_hssize, native_herr,
  native_hbool, native_int8, native_uint8, native_int_least8, native_uint_least8,
  native_int_fast8 , native_uint_fast8, native_int16, native_uint16, native_int_least16,
  native_uint_least16, native_int_fast16, native_uint_fast16, native_int32, native_uint32,
  native_int_least32, native_uint_least32, native_int_fast32, native_uint_fast32,
  native_int64, native_uint64, native_int_least64, native_uint_least64 ,
  native_int_fast64, native_uint_fast64 = datatypes ()

external to_loc : Hid.t -> Hid.t = "%identity"
external of_loc : Hid.t -> Hid.t = "%identity"

external create : Class.t -> int -> Hid.t = "hdf5_h5t_create"
external commit : Hid.t -> string -> ?lcpl:Hid.t -> ?tcpl:Hid.t -> ?tapl:Hid.t -> Hid.t
  -> unit = "hdf5_h5t_commit_bytecode" "hdf5_h5t_commit"
external copy : Hid.t -> Hid.t = "hdf5_h5t_copy"
external equal : Hid.t -> Hid.t -> bool = "hdf5_h5t_equal"
external get_class : Hid.t -> Class.t = "hdf5_h5t_get_class"
external set_size : Hid.t -> int -> unit = "hdf5_h5t_set_size"
external get_size : Hid.t -> int = "hdf5_h5t_get_size"
external get_native_type : Hid.t -> Direction.t -> Hid.t = "hdf5_h5t_get_native_type"
external close : Hid.t -> unit = "hdf5_h5t_close"
external get_order : Hid.t -> Order.t = "hdf5_h5t_get_order"
external set_order : Hid.t -> Order.t -> unit = "hdf5_h5t_set_order"
external get_strpad : Hid.t -> Str.t = "hdf5_h5t_get_strpad"
external set_strpad : Hid.t -> Str.t -> unit = "hdf5_h5t_set_strpad"
external get_nmembers : Hid.t -> int = "hdf5_h5t_get_nmembers"
external is_variable_str : Hid.t -> bool = "hdf5_h5t_is_variable_str"
external insert : Hid.t -> string -> int -> Hid.t -> unit = "hdf5_h5t_insert"
