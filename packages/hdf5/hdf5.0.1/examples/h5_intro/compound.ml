open Bigarray
open Hdf5_raw

let _FILE        = "SDScompound.h5"
let _DATASETNAME = "ArrayOfStructures"
let _LENGTH      = 10

module S1 = struct
  type t = (char, int8_unsigned_elt, c_layout) Array1.t

  let sizeof = 16

  let create n = Array1.create char c_layout (n * sizeof)

  let get_a t i =
    Array1.unsafe_get (Obj.magic t : (int32, int32_elt, c_layout) Array1.t)
      (i * 4)
  let set_a t i v =
    Array1.unsafe_set (Obj.magic t : (int32, int32_elt, c_layout) Array1.t)
      (i * 4) v
  let get_b t i =
    Array1.unsafe_get (Obj.magic t : (float, float32_elt, c_layout) Array1.t)
      (i * 4 + 1)
  let set_b t i v =
    Array1.unsafe_set (Obj.magic t : (float, float32_elt, c_layout) Array1.t)
      (i * 4 + 1) v
  let get_c t i =
    Array1.unsafe_get (Obj.magic t : (float, float64_elt, c_layout) Array1.t)
      (i * 2 + 1)
  let set_c t i v =
    Array1.unsafe_set (Obj.magic t : (float, float64_elt, c_layout) Array1.t)
      (i * 2 + 1) v
end

module S2 = struct
  type t = {
    t0 : (char, int8_unsigned_elt, c_layout) Array1.t;
    t4 : (char, int8_unsigned_elt, c_layout) Array1.t;
  }

  let sizeof = 12

  let create n =
    let t0 = Array1.create char c_layout (n * sizeof) in
    let t4 = Array1.sub t0 4 (n * sizeof - 4) in
    { t0; t4 }

  let get_c t i =
    if i land 1 = 0 then
      Array1.unsafe_get (Obj.magic t.t0 : (float, float64_elt, c_layout) Array1.t)
        (i / 2 * 3)
    else
      Array1.unsafe_get (Obj.magic t.t4 : (float, float64_elt, c_layout) Array1.t)
        (i / 2 * 3 + 1)
  let set_c t i v =
    if i land 1 = 0 then
      Array1.unsafe_set (Obj.magic t.t0 : (float, float64_elt, c_layout) Array1.t)
        (i / 2 * 3) v
    else
      Array1.unsafe_set (Obj.magic t.t4 : (float, float64_elt, c_layout) Array1.t)
        (i / 2 * 3 + 1) v
  let get_a t i =
    Array1.unsafe_get (Obj.magic t.t0 : (int32, int32_elt, c_layout) Array1.t)
      (i * 3 + 2)
  let set_a t i v =
    Array1.unsafe_set (Obj.magic t.t0 : (int32, int32_elt, c_layout) Array1.t)
      (i * 3 + 2) v
end

let () =
  let s1 = S1.create _LENGTH in
  let s2 = S2.create _LENGTH in
  let s3 = Array1.create float32 c_layout _LENGTH in
  for i = 0 to _LENGTH - 1 do
    S1.set_a s1 i (Int32.of_int i);
    S1.set_b s1 i (float_of_int (i * i));
    S1.set_c s1 i (1. /. float_of_int (i + 1))
  done;

  let space = H5s.create_simple [| _LENGTH |] in
  let file = H5f.create _FILE H5f.Acc.([ TRUNC ]) in
  let s1_tid = H5t.create H5t.Class.COMPOUND S1.sizeof in
  H5t.insert s1_tid "a_name" 0 H5t.native_int;
  H5t.insert s1_tid "c_name" 8 H5t.native_double;
  H5t.insert s1_tid "b_name" 4 H5t.native_float;

  let dataset = H5d.create file _DATASETNAME s1_tid space in
  H5d.write dataset s1_tid H5s.all H5s.all (genarray_of_array1 s1);
  H5t.close s1_tid;
  H5s.close space;
  H5d.close dataset;
  H5f.close file;

  let file = H5f.open_ _FILE H5f.Acc.([ RDONLY ]) in
  let dataset = H5d.open_ file _DATASETNAME in
  let s2_tid = H5t.create H5t.Class.COMPOUND S2.sizeof in
  H5t.insert s2_tid "c_name" 0 H5t.native_double;
  H5t.insert s2_tid "a_name" 8 H5t.native_int;
  H5d.read dataset s2_tid H5s.all H5s.all (genarray_of_array1 s2.S2.t0);

  Printf.printf "\n";
  Printf.printf "Field c : \n";
  for i = 0 to _LENGTH - 1 do
    Printf.printf "%.4f " (S2.get_c s2 i)
  done;
  Printf.printf "\n";

  Printf.printf "\n";
  Printf.printf "Field a : \n";
  for i = 0 to _LENGTH - 1 do
    Printf.printf "%ld " (S2.get_a s2 i)
  done;
  Printf.printf "\n";

  let s3_tid = H5t.create H5t.Class.COMPOUND 4 in
  H5t.insert s3_tid "b_name" 0 H5t.native_float;
  H5d.read dataset s3_tid H5s.all H5s.all (genarray_of_array1 s3);

  Printf.printf "\n";
  Printf.printf "Field b : \n";
  for i = 0 to _LENGTH - 1 do
    Printf.printf "%.4f " s3.{i}
  done;
  Printf.printf "\n";

  H5t.close s2_tid;
  H5t.close s3_tid;
  H5d.close dataset;
  H5f.close file
