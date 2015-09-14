open Hdf5_raw

let _FILE = "group.h5"

let file_info loc_id name () =
  let grp = H5g.open_ loc_id name in
  Printf.printf "\n";
  Printf.printf "Name : ";
  print_endline name;
  H5g.close grp;
  H5.Iter.CONT

let () =
  let file = H5f.create _FILE H5f.Acc.([ TRUNC ]) in
  let _ = H5g.create file "/Data" in
  let dataspace = H5s.create_simple [| 1000; 20 |] in
  let plist = H5p.create H5p.Cls_id.DATASET_CREATE in
  H5p.set_chunk plist [| 20; 20 |];
  H5p.set_deflate plist 6;
  let dataset = H5d.create file "/Data/Compressed_Data" H5t.native_int ~dcpl:plist
    dataspace in
  H5s.close dataspace;
  H5d.close dataset;
  H5f.close file;

  let file = H5f.open_ _FILE H5f.Acc.([ RDWR ]) in
  let grp = H5g.open_ file "Data" in
  let dataset = H5d.open_ grp "Compressed_Data" in
  Printf.printf "\"/Data/Compressed_Data\" dataset is open \n";
  H5d.close dataset;
  H5g.link file H5l.Type.HARD ~current_name:"Data" ~new_name:"Data_new";
  let dataset = H5d.open_ file "/Data_new/Compressed_Data" in
  Printf.printf "\"/Data_new/Compressed_Data\" dataset is open \n%!";
  H5d.close dataset;

  let _ = H5g.iterate file "/" file_info () in
  H5g.unlink file "Data";
  Printf.printf "\"Data\" is unlinked \n";
  let _ = H5g.iterate file "/" file_info () in
  H5f.close file
