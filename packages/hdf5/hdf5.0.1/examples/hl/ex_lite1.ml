open Bigarray
open Hdf5_raw

let () =
  let data = Array2.of_array int32 c_layout
    [| [| 1l; 2l |]; [| 3l; 4l |]; [| 5l; 6l |] |] in
  let file_id = H5f.create "ex_lite1.h5" H5f.Acc.([ TRUNC ]) in
  H5lt.make_dataset file_id "/dset" H5t.native_int (genarray_of_array2 data);
  H5f.close file_id
