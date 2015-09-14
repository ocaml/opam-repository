open Bigarray
open Hdf5_raw

let _ATTR_SIZE = 5

let () =
  let data = Array1.of_array int32 c_layout [| 1l; 2l; 3l; 4l; 5l |] in
  let file_id = H5f.create "ex_lite3.h5" H5f.Acc.([ TRUNC ]) in
  let space_id = H5s.create_simple [| _ATTR_SIZE |] in
  let dset_id = H5d.create file_id "dset" H5t.native_int space_id in
  H5d.close dset_id;
  H5s.close space_id;
  H5lt.set_attribute_int32 file_id "dset" "attr1" data;
  H5lt.get_attribute_int32 file_id "dset" "attr1" data;
  for i = 0 to _ATTR_SIZE - 1 do
    Printf.printf "  %ld" data.{i}
  done;
  Printf.printf "\n";
  H5f.close file_id
