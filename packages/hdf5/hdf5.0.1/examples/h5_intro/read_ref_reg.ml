open Bigarray
open Hdf5_raw

let _FILE2       = "trefer2.h5"
let _NPOINTS     = 10
let _SPACE1_NAME = "Space1"
let _SPACE1_DIM1 = 4
let _SPACE2_NAME = "Space2"
let _SPACE2_DIM1 = 10
let _SPACE2_DIM2 = 10

let () =
  let rbuf = H5r.Hdset_reg_ref.Bigarray.create _SPACE1_DIM1 in
  let drbuf = Array1.create int32 c_layout (_SPACE2_DIM1 * _SPACE2_DIM2) in
  let fid1 = H5f.open_ _FILE2 H5f.Acc.([ RDWR ]) in
  let dset1 = H5d.open_ fid1 "/Dataset1" in
  H5d.read dset1 H5t.std_ref_dsetreg H5s.all H5s.all
    (H5r.Hdset_reg_ref.Bigarray.to_genarray rbuf);
  let dset2 = H5r.Hdset_reg_ref.(dereference dset1 (Bigarray.unsafe_get rbuf 0)) in
  let sid1 = H5d.get_space dset2 in
  let ret = H5s.get_simple_extent_npoints sid1 in
  Printf.printf " Number of elements in the dataset is : %d\n" ret;
  H5d.read dset2 H5t.native_int H5s.all H5s.all (genarray_of_array1 drbuf);
  for i = 0 to _SPACE2_DIM1 - 1 do
    for j = 0 to _SPACE2_DIM2 - 1 do
      Printf.printf " %ld " drbuf.{i * _SPACE2_DIM2 + j}
    done;
    Printf.printf "\n"
  done;
  let sid2 = H5r.Hdset_reg_ref.(get_region dset1 (Bigarray.unsafe_get rbuf 0)) in
  let ret = H5s.get_select_npoints sid2 in
  Printf.printf " Number of elements in the hyperslab is : %d \n" ret;
  let coords = H5s.get_select_hyper_blocklist sid2 in
  Printf.printf " Hyperslab coordinates are : \n";
  Printf.printf " ( %d , %d ) ( %d , %d ) \n" coords.(0) coords.(1) coords.(2) coords.(3);
  let _ = H5s.get_select_bounds sid2 in
  H5s.close sid2;
  let sid2 = H5r.Hdset_reg_ref.(get_region dset1 (Bigarray.unsafe_get rbuf 1)) in
  let coords = H5s.get_select_elem_pointlist sid2 in
  let ret = Array.length coords / 4 in
  Printf.printf " Number of selected elements is : %d \n" ret;
  Printf.printf " Coordinates of selected elements are : \n";
  for i = 0 to _NPOINTS - 1 do
    let i = i * 2 in
    Printf.printf " ( %d , %d ) \n" coords.(i) coords.(i + 1)
  done;
  let _ = H5s.get_select_bounds sid2 in
  H5s.close sid2;
  H5s.close sid1;
  H5d.close dset2;
  H5d.close dset1;
  H5f.close fid1
