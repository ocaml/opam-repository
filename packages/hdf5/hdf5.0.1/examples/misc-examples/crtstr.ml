open Hdf5_raw

let _FILE = "chard.h5"

let () =
  let file_id = H5f.create _FILE H5f.Acc.([ TRUNC ]) in
  let dataspace_id = H5s.create H5s.Class.SCALAR in
  let dtype = H5t.copy H5t.c_s1 in
  H5t.set_size dtype 16;
  let dataset_id = H5d.create file_id "Char Data" dtype dataspace_id in
  H5d.write dataset_id dtype H5s.all H5s.all "This is a test.";
  H5d.close dataset_id;
  H5s.close dataspace_id;
  H5f.close file_id
