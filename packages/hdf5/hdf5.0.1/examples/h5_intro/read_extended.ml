open Bigarray
open Hdf5_raw

let _FILE        = "SDSextendible.h5"
let _DATASETNAME = "ExtendibleArray"
let _NX          = 10
let _NY          = 5

let () =
  let data_out = Array2.create int32 c_layout _NX _NY in
  let chunk_out = Array2.create int32 c_layout 2 5 in
  let column = Array1.create int32 c_layout 10 in
  let file = H5f.open_ _FILE H5f.Acc.([ RDONLY ]) in
  let dataset = H5d.open_ file _DATASETNAME in
  let filespace = H5d.get_space dataset in
  let dims, _ = H5s.get_simple_extent_dims filespace in
  Printf.printf "dataset rank %d, dimensions %d x %d\n"
    (Array.length dims) dims.(0) dims.(1);
  let cparms = H5d.get_create_plist dataset in
  assert (Layout.CHUNKED = H5p.get_layout cparms);
  let chunk_dims = H5p.get_chunk cparms in
  Printf.printf "chunk rank %d, dimensions %d x %d\n"
    (Array.length chunk_dims) chunk_dims.(0) chunk_dims.(1);
  let memspace = H5s.create_simple dims in
  H5d.read dataset H5t.native_int memspace filespace (genarray_of_array2 data_out);
  Printf.printf "\n";
  Printf.printf "Dataset: \n";
  for j = 0 to dims.(0) - 1 do
    for i = 0 to dims.(1) - 1 do
      Printf.printf "%ld " data_out.{j, i}
    done;
    Printf.printf "\n"
  done;

  let memspace = H5s.create_simple [| 10 |] in
  H5s.select_hyperslab filespace H5s.Select.SET ~start:[| 0; 2 |] ~count:[| 10; 1 |] ();
  H5d.read dataset H5t.native_int memspace filespace (genarray_of_array1 column);
  Printf.printf "\n";
  Printf.printf "Third column: \n";
  for i = 0 to 9 do
    Printf.printf "%ld \n" column.{i}
  done;

  let memspace = H5s.create_simple chunk_dims in
  H5s.select_hyperslab filespace H5s.Select.SET ~start:[| 2; 0 |] ~count:chunk_dims ();
  H5d.read dataset H5t.native_int memspace filespace (genarray_of_array2 chunk_out);
  Printf.printf "\n";
  Printf.printf "Chunk: \n";
  for j = 0 to chunk_dims.(0) - 1 do
    for i = 0 to chunk_dims.(1) - 1 do
      Printf.printf "%ld " chunk_out.{j, i}
    done;
    Printf.printf "\n"
  done;

  H5p.close cparms;
  H5d.close dataset;
  H5s.close filespace;
  H5s.close memspace;
  H5f.close file
