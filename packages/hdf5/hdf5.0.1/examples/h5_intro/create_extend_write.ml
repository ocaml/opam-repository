open Bigarray
open Hdf5_raw

let _FILE        = "SDSextendible.h5"
let _DATASETNAME = "ExtendibleArray"

let () =
  let data1 = Array2.of_array int32 c_layout
    [| [| 1l; 1l; 1l |];
       [| 1l; 1l; 1l |];
       [| 1l; 1l; 1l |] |] in
  let data2 = Array1.of_array int32 c_layout [| 2l; 2l; 2l; 2l; 2l; 2l; 2l |] in
  let data3 = Array2.of_array int32 c_layout
    [| [| 3l; 3l |];
       [| 3l; 3l |] |] in

  let dataspace = H5s.create_simple ~maximum_dims:Hsize.([| unlimited; unlimited |])
    [| 3; 3 |] in
  let file = H5f.create _FILE H5f.Acc.([ TRUNC ]) in
  let cparms = H5p.create H5p.Cls_id.DATASET_CREATE in
  H5p.set_chunk cparms [| 2; 5 |];
  let dataset = H5d.create file _DATASETNAME H5t.native_int ~dcpl:cparms dataspace in
  H5d.extend dataset [| 3; 3 |];
  let filespace = H5d.get_space dataset in
  H5s.select_hyperslab filespace H5s.Select.SET ~start:[| 0; 0 |] ~count:[| 3; 3 |] ();
  H5d.write dataset H5t.native_int dataspace filespace (genarray_of_array2 data1);
  H5d.extend dataset [| 10; 3 |];
  let filespace = H5d.get_space dataset in
  H5s.select_hyperslab filespace H5s.Select.SET ~start:[| 3; 0 |] ~count:[| 7; 1 |] ();
  let dataspace = H5s.create_simple [| 7; 1 |] in
  H5d.write dataset H5t.native_int dataspace filespace (genarray_of_array1 data2);
  H5d.extend dataset [| 10; 5 |];
  let filespace = H5d.get_space dataset in
  H5s.select_hyperslab filespace H5s.Select.SET ~start:[| 0; 3 |] ~count:[| 2; 2 |] ();
  let dataspace = H5s.create_simple [| 2; 2 |] in
  H5d.write dataset H5t.native_int dataspace filespace (genarray_of_array2 data3);
  H5d.close dataset;
  H5s.close dataspace;
  H5s.close filespace;
  H5f.close file
