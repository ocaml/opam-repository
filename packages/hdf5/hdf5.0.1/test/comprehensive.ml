open Bigarray
open Hdf5_raw
open Hdf5_caml

module H5 = H5caml

let _FILE = "test.h5"
let _NX   = 5
let _NY   = 6

let () =
  let int32array = Array2.create int32 c_layout _NX _NY in
  for j = 0 to _NX - 1 do
    for i = 0 to _NY - 1 do
      int32array.{j, i} <- Int32.of_int (i + j)
    done
  done;

  let file = H5f.create _FILE H5f.Acc.([ TRUNC ]) in
  assert (H5f.get_name file = _FILE);

  let group_a = H5g.create file "A" in
  let group_aa = H5g.create group_a "A" in
  let group_ab = H5g.create group_a "B" in

  let dataspace = H5s.create_simple [| _NX; _NY |] in

  let dataset_aaa = H5d.create group_aa "A" H5t.native_int dataspace in
  H5d.write dataset_aaa H5t.native_int H5s.all H5s.all int32array;
  H5d.close dataset_aaa;

  let dataset_aab = H5d.create group_aa "B" H5t.native_int dataspace in
  H5d.write dataset_aab H5t.native_int H5s.all H5s.all int32array;
  H5d.close dataset_aab;

  let dataset_aba = H5d.create group_ab "A" H5t.native_int dataspace in
  H5d.write dataset_aba H5t.native_int H5s.all H5s.all int32array;
  H5d.close dataset_aba;

  let dataset_abb = H5d.create group_ab "B" H5t.native_int dataspace in
  H5d.write dataset_abb H5t.native_int H5s.all H5s.all int32array;
  H5d.close dataset_abb;

  H5g.close group_aa;
  H5g.close group_ab;
  H5g.close group_a;

  let dest = H5f.create "dest.h5" H5f.Acc.([ TRUNC ]) in
  let group_a = H5g.create dest "A" in
  let group_aa = H5g.create group_a "A" in

  let dataset_aab = H5d.create group_aa "B" H5t.native_int dataspace in
  H5d.write dataset_aab H5t.native_int H5s.all H5s.all int32array;
  H5d.close dataset_aab;

  H5g.close group_aa;
  H5g.close group_a;

  H5s.close dataspace;
  H5f.close dest;
  H5f.close file;

  let src = H5.open_rdonly _FILE in
  let dst = H5.open_rdwr "dest.h5" in
  H5.merge ~src ~dst;
  H5.close src;
  H5.close dst;

  let dest = H5f.open_ "dest.h5" H5f.Acc.([ RDONLY ]) in
  let group_a = H5g.open_ dest "A" in
  let group_aa = H5g.open_ group_a "A" in
  let dataset = H5d.open_ group_aa "A" in
  let dataspace = H5d.get_space dataset in
  let datatype = H5d.get_type dataset in
  let int32array = Array2.create int32 c_layout _NX _NY in
  H5d.read dataset datatype dataspace dataspace int32array;
  H5t.close datatype;
  H5s.close dataspace;
  H5d.close dataset;
  H5g.close group_aa;
  H5g.close group_a;
  H5f.close dest
