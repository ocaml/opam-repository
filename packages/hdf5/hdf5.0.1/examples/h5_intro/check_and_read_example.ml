open Bigarray
open Hdf5_raw

let _FILE        = "SDS.h5"
let _DATASETNAME = "IntArray"
let _NX_SUB      = 3
let _NY_SUB      = 4
let _NX          = 7
let _NY          = 7
let _NZ          = 3

let () =
  let data_out = Array3.create int32 c_layout _NX _NY _NZ in
  for j = 0 to _NX - 1 do
    for i = 0 to _NY - 1 do
      for k = 0 to _NZ - 1 do
        data_out.{j, i, k} <- Int32.zero
      done
    done
  done;

  let file = H5f.open_ _FILE [ H5f.Acc.RDONLY ] in
  let dataset = H5d.open_ file _DATASETNAME in
  let datatype = H5d.get_type dataset in
  let class_ = H5t.get_class datatype in
  if class_ = H5t.Class.INTEGER then Printf.printf "Data set has INTEGER type\n";
  let order = H5t.get_order datatype in
  if order = H5t.Order.LE then Printf.printf "Little endian order\n";
  let size = H5t.get_size datatype in
  Printf.printf "Data size is %d\n" size;
  let dataspace = H5d.get_space dataset in
  let status_n, _ = H5s.get_simple_extent_dims dataspace in
  Printf.printf "rank %d, dimensions %d x %d\n" (Array.length status_n) status_n.(0)
    status_n.(1);
  H5s.select_hyperslab dataspace H5s.Select.SET
    ~start:[| 1; 2 |]
    ~count:[| _NX_SUB; _NY_SUB |] ();
  let memspace = H5s.create_simple [| _NX; _NY; _NZ |] in
  H5s.select_hyperslab memspace H5s.Select.SET
    ~start:[| 3; 0; 0 |]
    ~count:[| _NX_SUB; _NY_SUB; 1 |] ();
  H5d.read dataset H5t.native_int memspace dataspace (genarray_of_array3 data_out);
  for j = 0 to _NX - 1 do
    for i = 0 to _NY - 1 do
      Printf.printf "%ld " data_out.{j, i, 0}
    done;
    Printf.printf "\n"
  done;
  H5t.close datatype;
  H5d.close dataset;
  H5s.close dataspace;
  H5s.close memspace;
  H5f.close file
