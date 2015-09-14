open Bigarray
open Hdf5_raw

let _FILE        = "Select.h5"
let _MSPACE1_DIM = 50
let _MSPACE2_DIM = 4
let _FSPACE_DIM1 = 8
let _FSPACE_DIM2 = 12
let _MSPACE_DIM1 = 8
let _MSPACE_DIM2 = 12

let () =
  let matrix = Array2.create int32 c_layout _MSPACE_DIM1 _MSPACE_DIM2 in
  let vector = Array1.create int32 c_layout _MSPACE1_DIM in
  let values = Array1.create int32 c_layout 4 in
  
  vector.{0}                <- Int32.of_int (-1);
  vector.{_MSPACE1_DIM - 1} <- Int32.of_int (-1);
  for i = 1 to _MSPACE1_DIM - 2 do
    vector.{i} <- Int32.of_int i
  done;
  for i = 0 to _MSPACE_DIM1 - 1 do
    for j = 0 to _MSPACE_DIM2 - 1 do
      matrix.{i, j} <- Int32.zero
    done
  done;
  values.{0} <- Int32.of_int 53;
  values.{1} <- Int32.of_int 59;
  values.{2} <- Int32.of_int 61;
  values.{3} <- Int32.of_int 67;

  let file = H5f.create _FILE [ H5f.Acc.TRUNC ] in
  let fid = H5s.create_simple [| _FSPACE_DIM1; _FSPACE_DIM2 |] in
  let dataset = H5d.create file "Matrix in file" H5t.native_int fid in
  H5d.write dataset H5t.native_int H5s.all H5s.all (genarray_of_array2 matrix);
  H5s.select_hyperslab fid H5s.Select.SET
    ~start: [| 0; 1 |]
    ~stride:[| 4; 3 |]
    ~count: [| 2; 4 |]
    ~block: [| 3; 2 |] ();
  let mid1 = H5s.create_simple [| _MSPACE1_DIM |] in
  H5s.select_hyperslab mid1 H5s.Select.SET
    ~start: [| 1 |]
    ~stride:[| 1 |]
    ~count: [| 48 |]
    ~block: [| 1 |] ();
  H5d.write dataset H5t.native_int mid1 fid (genarray_of_array1 vector);
  H5s.select_none fid;
  let mid2 = H5s.create_simple [| _MSPACE2_DIM |] in
  H5s.select_elements fid H5s.Select.SET
    [| 0; 0;
       3; 3;
       3; 5;
       5; 6 |];
  H5d.write dataset H5t.native_int mid2 fid (genarray_of_array1 values);
  H5s.close mid1;
  H5s.close mid2;
  H5s.close fid;
  H5d.close dataset;
  H5f.close file;
  let file = H5f.open_ _FILE [ H5f.Acc.RDONLY ] in
  let dataset = H5d.open_ file "Matrix in file" in
  H5d.read dataset H5t.native_int H5s.all H5s.all (genarray_of_array2 matrix);
  for i = 0 to _MSPACE_DIM1 - 1 do
    for j = 0 to _MSPACE_DIM2 - 1 do
      Printf.printf "%3ld  " matrix.{i, j}
    done;
    Printf.printf "\n"
  done
