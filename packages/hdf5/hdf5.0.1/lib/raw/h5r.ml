open Bigarray

external string_get32u    : bytes      -> int -> int32         = "%caml_string_get32u"
external string_set32u    : bytes      -> int -> int32 -> unit = "%caml_string_set32u"
external string_get64u    : bytes      -> int -> int64         = "%caml_string_get64u"
external string_set64u    : bytes      -> int -> int64 -> unit = "%caml_string_set64u"
external bigstring_get32u : _ Array1.t -> int -> int32         = "%caml_bigstring_get32u"
external bigstring_set32u : _ Array1.t -> int -> int32 -> unit = "%caml_bigstring_set32u"
external bigstring_get64u : _ Array1.t -> int -> int64         = "%caml_bigstring_get64u"
external bigstring_set64u : _ Array1.t -> int -> int64 -> unit = "%caml_bigstring_set64u"

module Type = struct
  type t =
  | OBJECT
  | DATASET_REGION
end

external create : Hid.t -> string -> ?space:Hid.t -> Type.t -> bytes = "hdf5_h5r_create"
external dereference : Hid.t -> Type.t -> bytes -> Hid.t = "hdf5_h5r_dereference"
external get_region : Hid.t -> Type.t -> bytes -> Hid.t = "hdf5_h5r_get_region"

module Hobj_ref = struct
  type t = bytes
  let create loc ?space name = create loc name ?space Type.OBJECT
  let dereference loc t = dereference loc Type.OBJECT t
  let get_region loc t = get_region loc Type.OBJECT t
  module Bigarray = struct
    type hobj_ref = t
    type t = (char, int8_unsigned_elt, c_layout) Array1.t

    let create len = Array1.create char c_layout (len * 8)
    let unsafe_get (t : t) i =
      let i = i * 8 in
      let x = Bytes.create 8 in
      string_set64u x 0 (bigstring_get64u t (i + 0));
      x
    let unsafe_set (t : t) i (x : hobj_ref) =
      let i = i * 8 in
      bigstring_set64u t (i + 0) (string_get64u x 0)
    let to_genarray t = genarray_of_array1 t
  end
end

module Hdset_reg_ref = struct
  type t = bytes
  let create loc ?space name = create loc name ?space Type.DATASET_REGION
  let dereference loc t = dereference loc Type.DATASET_REGION t
  let get_region loc t = get_region loc Type.DATASET_REGION t
  module Bigarray = struct
    type hdset_reg_ref = t
    type t = (char, int8_unsigned_elt, c_layout) Array1.t

    let create len = Array1.create char c_layout (len * 12)
    let unsafe_get (t : t) i =
      let i = i * 12 in
      let x = Bytes.create 12 in
      string_set64u x 0 (bigstring_get64u t (i + 0));
      string_set32u x 8 (bigstring_get32u t (i + 8));
      x
    let unsafe_set (t : t) i (x : hdset_reg_ref) =
      let i = i * 12 in
      bigstring_set64u t (i + 0) (string_get64u x 0);
      bigstring_set32u t (i + 8) (string_get32u x 8)
    let to_genarray t = genarray_of_array1 t
  end
end

