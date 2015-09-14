open Hdf5_raw

let _H5FILE_NAME = "interm_group.h5"

let () =
  let file = H5f.create _H5FILE_NAME H5f.Acc.([ TRUNC ]) in
  let h1_id = H5g.create file "/G1" in
  H5g.close h1_id;
  H5f.close file;

  let file = H5f.open_ _H5FILE_NAME H5f.Acc.([ RDWR ]) in
  if H5l.exists file "/G1" then
    Printf.printf "Group /G1 exists in the file\n";
  let g1_id = H5g.open_ file "/G1" in
  if not (H5l.exists h1_id "G2") then begin
    let grp_crt_plist = H5p.create H5p.Cls_id.LINK_CREATE in
    H5p.set_create_intermediate_group grp_crt_plist true;
    let g3_id = H5g.create h1_id "G2/G3" ~lcpl:grp_crt_plist in
    H5g.close g3_id
  end;
  H5g.close g1_id;

  if H5l.exists file "/G1/G2" then begin
    let g2_id = H5g.open_ file "/G1/G2" in
    let g2_info = H5g.get_info g2_id in
    Printf.printf "Group /G1/G2 has %d member(s)\n" g2_info.H5g.Info.nlinks;
    for i = 0 to g2_info.H5g.Info.nlinks - 1 do
      let name = H5l.get_name_by_idx g2_id "." H5.Index.NAME H5.Iter_order.NATIVE i in
      Printf.printf "Object's name is %s\n" name
    done;
    H5g.close g2_id
  end;
  H5f.close file
