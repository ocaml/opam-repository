open Hdf5_raw

let _SPACE1_DIM = 4
let _DSET_VLSTR_NAME = "vlstr_type"

let () =
  let wdata = [|
    "Four score and seven years ago our forefathers brought forth on this continent a new nation,";
    "conceived in liberty and dedicated to the proposition that all men are created equal.";
    "Now we are engaged in a great civil war,";
    "testing whether that nation or any nation so conceived and so dedicated can long endure."
  |] in
  let file = H5f.create "varlen.h5" H5f.Acc.([ TRUNC ]) in
  let sid1 = H5s.create_simple [| _SPACE1_DIM |] in
  let tid1 = H5t.copy H5t.c_s1 in
  H5t.set_size tid1 H5t.variable;
  if H5t.get_class tid1 <> H5t.Class.STRING then
    failwith "this is not a variable length string type!!!";
  let dataset = H5d.create file _DSET_VLSTR_NAME tid1 sid1 in
  H5d.write dataset tid1 H5s.all H5s.all wdata;
  H5d.close dataset;
  let dataset = H5d.open_ file _DSET_VLSTR_NAME in
  let dtype = H5d.get_type dataset in
  let native_type = H5t.get_native_type dtype H5t.Direction.DEFAULT in
  if not (H5t.equal native_type tid1) then
    failwith "native type is not tid1!!!";
  let xfer_plist = H5p.create H5p.Cls_id.DATASET_XFER in
  H5p.set_vlen_mem_manager xfer_plist (fun i -> Bytes.create (i - 1)) (fun _ -> ());
  let rdata = Array.make 1024 "" in
  H5d.read dataset dtype H5s.all H5s.all ~xfer_plist rdata;
  Printf.printf "data read:\n";
  for i = 0 to _SPACE1_DIM - 1 do
    if wdata.(i) <> rdata.(i) then
      failwith (Printf.sprintf
        "    VL data values don't match!, wdata[%d]=%s, rdata[%d]=%s\n"
        i wdata.(i) i rdata.(i))
    else
      Printf.printf "%s" rdata.(i)
  done;
  Printf.printf "\n"
