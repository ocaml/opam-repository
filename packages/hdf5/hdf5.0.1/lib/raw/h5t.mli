module Class : sig
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

module Order : sig
  type t =
  | ERROR
  | LE
  | BE
  | VAX
  | NONE
end

module Sign : sig
  type t =
  | NONE
  | SIGN_2
  | NSGN
end

module Norm : sig
  type t =
  | IMPLIED
  | MSBSET
  | NONE
end

module Cset : sig
  type t =
  | ASCII
  | UTF8
end

module Str : sig
  type t =
  | NULLTERM
  | NULLPAD
  | SPACEPAD
end

module Pad : sig
  type t =
  | ZERO
  | ONE
  | BACKGROUND
  | NPAD
end

module Cmd : sig
  type t =
  | INIT
  | CONV
  | FREE
end

module Bkg : sig
  type t =
  | NO
  | TEMP
  | YES
end

module Cdata : sig
  type t = {
    command  : Cmd.t;
    need_bkg : Bkg.t;
    recalc   : bool;
    priv     : int64 }
end

module Pers : sig
  type t =
  | DONTCARE
  | HARD
  | SOFT
end

module Direction : sig
  type t =
  | DEFAULT
  | ASCEND
  | DESCEND
end

module Conv_except : sig
  type t =
  | RANGE_HI
  | RANGE_LOW
  | PRECISION
  | TRUNCATE
  | PINF
  | NINF
  | NAN
end

module Conv_ret : sig
  type t =
  | ABORT
  | UNHANDLED
  | HANDLED
end

val variable : int

val ieee_f32be : Hid.t
val ieee_f32le : Hid.t
val ieee_f64be : Hid.t
val ieee_f64le : Hid.t
val std_i8be : Hid.t
val std_i8le : Hid.t
val std_i16be : Hid.t
val std_i16le : Hid.t
val std_i32be : Hid.t
val std_i32le : Hid.t
val std_i64be : Hid.t
val std_i64le : Hid.t
val std_u8be : Hid.t
val std_u8le : Hid.t
val std_u16be : Hid.t
val std_u16le : Hid.t
val std_u32be : Hid.t
val std_u32le : Hid.t
val std_u64be : Hid.t
val std_u64le : Hid.t
val std_b8be : Hid.t
val std_b8le : Hid.t
val std_b16be : Hid.t
val std_b16le : Hid.t
val std_b32be : Hid.t
val std_b32le : Hid.t
val std_b64be : Hid.t
val std_b64le : Hid.t
val std_ref_obj : Hid.t
val std_ref_dsetreg : Hid.t
val unix_d32be : Hid.t
val unix_d32le : Hid.t
val unix_d64be : Hid.t
val unix_d64le : Hid.t
val c_s1 : Hid.t
val fortran_s1 : Hid.t
val intel_i8 : Hid.t
val intel_i16 : Hid.t
val intel_i32 : Hid.t
val intel_i64 : Hid.t
val intel_u8 : Hid.t
val intel_u16 : Hid.t
val intel_u32 : Hid.t
val intel_u64 : Hid.t
val intel_b8 : Hid.t
val intel_b16 : Hid.t
val intel_b32 : Hid.t
val intel_b64 : Hid.t
val intel_f32 : Hid.t
val intel_f64 : Hid.t
val alpha_i8 : Hid.t
val alpha_i16 : Hid.t
val alpha_i32 : Hid.t
val alpha_i64 : Hid.t
val alpha_u8 : Hid.t
val alpha_u16 : Hid.t
val alpha_u32 : Hid.t
val alpha_u64 : Hid.t
val alpha_b8 : Hid.t
val alpha_b16 : Hid.t
val alpha_b32 : Hid.t
val alpha_b64 : Hid.t
val alpha_f32 : Hid.t
val alpha_f64 : Hid.t
val mips_i8 : Hid.t
val mips_i16 : Hid.t
val mips_i32 : Hid.t
val mips_i64 : Hid.t
val mips_u8 : Hid.t
val mips_u16 : Hid.t
val mips_u32 : Hid.t
val mips_u64 : Hid.t
val mips_b8 : Hid.t
val mips_b16 : Hid.t
val mips_b32 : Hid.t
val mips_b64 : Hid.t
val mips_f32 : Hid.t
val mips_f64 : Hid.t
val vax_f32 : Hid.t
val vax_f64 : Hid.t
val native_char : Hid.t
val native_schar : Hid.t
val native_uchar : Hid.t
val native_short : Hid.t
val native_ushort : Hid.t
val native_int : Hid.t
val native_uint : Hid.t
val native_long : Hid.t
val native_ulong : Hid.t
val native_llong : Hid.t
val native_ullong : Hid.t
val native_float : Hid.t
val native_double : Hid.t
val native_ldouble : Hid.t
val native_b8 : Hid.t
val native_b16 : Hid.t
val native_b32 : Hid.t
val native_b64 : Hid.t
val native_opaque : Hid.t
val native_haddr : Hid.t
val native_hsize : Hid.t
val native_hssize : Hid.t
val native_herr : Hid.t
val native_hbool : Hid.t
val native_int8 : Hid.t
val native_uint8 : Hid.t
val native_int_least8 : Hid.t
val native_uint_least8 : Hid.t
val native_int_fast8  : Hid.t
val native_uint_fast8 : Hid.t
val native_int16 : Hid.t
val native_uint16 : Hid.t
val native_int_least16 : Hid.t
val native_uint_least16 : Hid.t
val native_int_fast16 : Hid.t
val native_uint_fast16 : Hid.t
val native_int32 : Hid.t
val native_uint32 : Hid.t
val native_int_least32 : Hid.t
val native_uint_least32 : Hid.t
val native_int_fast32 : Hid.t
val native_uint_fast32 : Hid.t
val native_int64 : Hid.t
val native_uint64 : Hid.t
val native_int_least64 : Hid.t
val native_uint_least64  : Hid.t
val native_int_fast64 : Hid.t
val native_uint_fast64 : Hid.t

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
external is_variable_str : Hid.t -> bool = "hdf5_h5t_is_variable_str"
external get_nmembers : Hid.t -> int = "hdf5_h5t_get_nmembers"
external insert : Hid.t -> string -> int -> Hid.t -> unit = "hdf5_h5t_insert"
