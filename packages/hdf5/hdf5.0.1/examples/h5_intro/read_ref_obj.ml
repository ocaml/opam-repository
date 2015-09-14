open Bigarray
open Hdf5_raw

let _FILE1       = "trefer1.h5"
let _SPACE1_NAME = "Space1"
let _SPACE1_DIM1 = 4

let () =
  let rbuf = H5r.Hobj_ref.Bigarray.create _SPACE1_DIM1 in
  let tu32 = Array1.create int32 c_layout _SPACE1_DIM1 in
  let fid1 = H5f.open_ _FILE1 H5f.Acc.([ RDWR ]) in
  let dataset = H5d.open_ fid1 "/Dataset3" in
  H5d.read dataset H5t.std_ref_obj H5s.all H5s.all
    (H5r.Hobj_ref.Bigarray.to_genarray rbuf);
  let dset2 = H5r.Hobj_ref.(dereference dataset (Bigarray.unsafe_get rbuf 0)) in
  let sid1 = H5d.get_space dset2 in
  let _ = H5s.get_simple_extent_npoints sid1 in
  H5d.read dset2 H5t.native_int H5s.all H5s.all (genarray_of_array1 tu32);
  Printf.printf "Dataset data : \n";
  for i = 0 to _SPACE1_DIM1 - 1 do
    Printf.printf " %ld " tu32.{i}
  done;
  Printf.printf "\n";
  Printf.printf "\n";
  H5d.close dset2;
  let group = H5r.Hobj_ref.(dereference dataset (Bigarray.unsafe_get rbuf 2)) in
  let read_comment = H5g.get_comment group "." in
  Printf.printf "Group comment is %s \n" read_comment;
  Printf.printf " \n";
  H5g.close group;
  let tid1 = H5r.Hobj_ref.(dereference dataset (Bigarray.unsafe_get rbuf 3)) in
  let tclass = H5t.get_class tid1 in
  if tclass = H5t.Class.COMPOUND then begin
    Printf.printf "Number of compound datatype members of %d \n" (H5t.get_nmembers tid1);
    Printf.printf " \n"
  end;
  H5t.close tid1;
  H5d.close dataset;
  H5f.close fid1
