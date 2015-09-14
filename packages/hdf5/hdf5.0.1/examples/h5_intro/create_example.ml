open Bigarray
open Hdf5_raw

let _FILE        = "SDS.h5"
let _DATASETNAME = "IntArray"
let _NX          = 5
let _NY          = 6

let () =
  let data = Array2.create int32 c_layout _NX _NY in
  for j = 0 to _NX - 1 do
    for i = 0 to _NY - 1 do
      data.{j, i} <- Int32.of_int (i + j)
    done
  done;
  let file = H5f.create _FILE [ H5f.Acc.TRUNC ] in
  let dataspace = H5s.create_simple [| _NX; _NY |] in
  let datatype = H5t.copy H5t.native_int in
  H5t.set_order datatype H5t.Order.LE;
  let dataset = H5d.create file _DATASETNAME datatype dataspace in
  H5d.write dataset H5t.native_int H5s.all H5s.all (genarray_of_array2 data);
  H5t.close datatype;
  H5d.close dataset;
  H5s.close dataspace;
  H5f.close file
