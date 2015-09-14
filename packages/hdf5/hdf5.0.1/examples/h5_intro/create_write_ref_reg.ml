open Bigarray
open Hdf5_raw

let _FILE2          = "trefer2.h5"
let _SPACE1_NAME    = "Space1"
let _SPACE1_DIM1    = 4
let _SPACE2_NAME    = "Space2"
let _SPACE2_DIM1    = 10
let _SPACE2_DIM2    = 10
let _POINT1_NPOINTS = 10

let () =
  let wbuf = H5r.Hdset_reg_ref.Bigarray.create _SPACE1_DIM1 in
  let dwbuf = Array1.create int32 c_layout (_SPACE2_DIM1 * _SPACE2_DIM2) in
  let fid1 = H5f.create _FILE2 H5f.Acc.([ TRUNC ]) in
  let sid2 = H5s.create_simple [| _SPACE2_DIM1; _SPACE2_DIM2 |] in
  let dset2 = H5d.create fid1 "Dataset2" H5t.std_u8le sid2 in
  for i = 0 to _SPACE2_DIM1 * _SPACE2_DIM2 - 1 do
    dwbuf.{i} <- Int32.of_int (i * 3)
  done;
  H5d.write dset2 H5t.native_int H5s.all H5s.all (genarray_of_array1 dwbuf);
  H5d.close dset2;
  let sid1 = H5s.create_simple [| _SPACE1_DIM1 |] in
  let dset1 = H5d.create fid1 "Dataset1" H5t.std_ref_dsetreg sid1 in
  H5s.select_hyperslab sid2 H5s.Select.SET ~start:[| 2; 2 |] ~stride:[| 1; 1 |]
    ~count:[| 6; 6 |] ~block:[| 1; 1 |] ();
  H5r.Hdset_reg_ref.(Bigarray.unsafe_set wbuf 0 (create fid1 ~space:sid2 "/Dataset2"));
  H5s.select_elements sid2 H5s.Select.SET [|
    6; 9;
    2; 2;
    8; 4;
    1; 6;
    2; 8;
    3; 2;
    0; 4;
    9; 0;
    7; 1;
    3; 3 |];
  H5r.Hdset_reg_ref.(Bigarray.unsafe_set wbuf 1 (create fid1 ~space:sid2 "/Dataset2"));
  H5d.write dset1 H5t.std_ref_dsetreg H5s.all H5s.all
    (H5r.Hdset_reg_ref.Bigarray.to_genarray wbuf);
  H5s.close sid1;
  H5d.close dset1;
  H5s.close sid2;
  H5f.close fid1
