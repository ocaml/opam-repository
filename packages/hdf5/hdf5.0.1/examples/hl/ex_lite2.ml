open Bigarray
open Hdf5_raw

let () =
  let data = Array1.create int32 c_layout 6 in
  let file_id = H5f.open_ "ex_lite1.h5" H5f.Acc.([ RDONLY ]) in
  H5lt.read_dataset_int32 file_id "/dset" (genarray_of_array1 data);
  let dataset_info = H5lt.get_dataset_info file_id "/dset" in
  let dims = dataset_info.H5lt.Dataset_info.dims in

  let n_values = dims.(0) * dims.(1) in
  let nrow = dims.(1) in
  for i = 0 to n_values / nrow - 1 do
    for j = 0 to nrow - 1 do
      Printf.printf "  %ld" data.{i * nrow + j}
    done;
    Printf.printf "\n"
  done;

  H5f.close file_id
