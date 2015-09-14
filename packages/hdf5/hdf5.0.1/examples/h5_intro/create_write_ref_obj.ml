open Bigarray
open Hdf5_raw

let _FILE1       = "trefer1.h5"
let _SPACE1_NAME = "Space1"
let _SPACE1_DIM1 = 4
let _SPACE2_NAME = "Space2"
let _SPACE2_DIM1 = 10
let _SPACE2_DIM2 = 10

module S1 = struct
  type t = (int32, int32_elt, c_layout) Array1.t

  let sizeof = 12

  let create n = Array1.create char c_layout (n * sizeof)

  let get_a t i   = Array1.unsafe_get t (i * 3)
  let set_a t i v = Array1.unsafe_set t (i * 3) v
  let get_b t i   = Array1.unsafe_get t (i * 3 + 1)
  let set_b t i v = Array1.unsafe_set t (i * 3 + 1) v
  let get_c t i =
    Array1.unsafe_get (Obj.magic t : (float, float32_elt, c_layout) Array1.t)
      (i * 3 + 2)
  let set_c t i v =
    Array1.unsafe_set (Obj.magic t : (float, float32_elt, c_layout) Array1.t)
      (i * 3 + 2) v
end

let () =
  let wbuf = H5r.Hobj_ref.Bigarray.create _SPACE1_DIM1 in
  let tu32 = Array1.create int32 c_layout _SPACE1_DIM1 in
  let fid1 = H5f.create _FILE1 H5f.Acc.([ TRUNC ]) in
  let sid1 = H5s.create_simple [| _SPACE1_DIM1 |] in
  let group = H5g.create fid1 "Group1" in
  H5g.set_comment group "." "Foo!";
  let dataset = H5d.create group "Dataset1" H5t.std_u32le sid1 in
  for i = 0 to _SPACE1_DIM1 - 1 do
    tu32.{i} <- Int32.of_int (i * 3)
  done;
  H5d.write dataset H5t.native_int H5s.all H5s.all (genarray_of_array1 tu32);
  H5d.close dataset;
  let dataset = H5d.create group "Dataset2" H5t.native_uchar sid1 in
  H5d.close dataset;
  let tid1 = H5t.create H5t.Class.COMPOUND S1.sizeof in
  H5t.insert tid1 "a" 0 H5t.native_int;
  H5t.insert tid1 "b" 4 H5t.native_int;
  H5t.insert tid1 "c" 8 H5t.native_float;
  H5t.commit group "Datatype1" tid1;
  H5t.close tid1;
  H5g.close group;
  let dataset = H5d.create fid1 "Dataset3" H5t.std_ref_obj sid1 in
  H5r.Hobj_ref.(Bigarray.unsafe_set wbuf 0 (create fid1 "/Group1/Dataset1"));
  H5r.Hobj_ref.(Bigarray.unsafe_set wbuf 1 (create fid1 "/Group1/Dataset2"));
  H5r.Hobj_ref.(Bigarray.unsafe_set wbuf 2 (create fid1 "/Group1"));
  H5r.Hobj_ref.(Bigarray.unsafe_set wbuf 3 (create fid1 "/Group1/Datatype1"));
  H5d.write dataset H5t.std_ref_obj H5s.all H5s.all
    (H5r.Hobj_ref.Bigarray.to_genarray wbuf);
  H5s.close sid1;
  H5d.close dataset;
  H5f.close fid1
