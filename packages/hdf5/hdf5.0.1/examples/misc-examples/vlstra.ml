open Hdf5_raw

let _VFILE = "vlstra.h5"
let _VDIM  = 4

let write_vlstr_attr () =
  let string_att = [| "string1"; "str2"; "strings123"; "str45" |] in
  let file = H5f.create _VFILE H5f.Acc.([ TRUNC ]) in
  let type_ = H5t.copy H5t.c_s1 in
  H5t.set_size type_ H5t.variable;
  let root = H5g.open_ file "/" in
  let dataspace = H5s.create_simple [| _VDIM |] in
  let att = H5a.create root "VarStrAtt" type_ dataspace in
  H5a.write att type_ string_att;
  H5a.close att;
  H5g.close root;
  H5t.close type_;
  H5s.close dataspace;
  H5f.close file

let read_vlstr_attr () =
  let string_att = Array.make 4 "" in
  let file = H5f.open_ _VFILE H5f.Acc.([ RDONLY ]) in
  let type_ = H5t.copy H5t.c_s1 in
  H5t.set_size type_ H5t.variable;
  let root = H5g.open_ file "/" in
  let att = H5a.open_name root "VarStrAtt" in
  H5a.read_vl att type_ string_att;
  for i = 0 to _VDIM - 1 do
    Printf.printf " (%i) %s\n" i string_att.(i)
  done;
  Printf.printf "\n";
  H5a.close att;
  H5t.close type_;
  H5g.close root;
  H5f.close file

let () =
  write_vlstr_attr ();
  read_vlstr_attr ()
