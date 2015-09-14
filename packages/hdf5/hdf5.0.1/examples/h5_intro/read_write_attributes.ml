open Bigarray
open Hdf5_raw

let _FILE   = "Attributes.h5"
let _SIZE   = 7
let _ADIM1  = 2
let _ADIM2  = 3
let _ANAME  = "Float attribute"
let _ANAMES = "Character attribute"

let array1_to_string (a : (char, int8_unsigned_elt, c_layout) Array1.t) =
  let len = Array1.dim a in
  let s = Bytes.create len in
  for i = 0 to len - 1 do
    Bytes.unsafe_set s i (Array1.unsafe_get a i)
  done;
  s

let attr_info loc_id name _ () =
  let attr = H5a.open_name loc_id name in
  Printf.printf "\n";
  Printf.printf "Name : ";
  print_endline name;

  let atype = H5a.get_type attr in
  let aspace = H5a.get_space attr in
  let sdim, _ = H5s.get_simple_extent_dims aspace in
  let rank = Array.length sdim in
  if rank > 0 then begin
    Printf.printf "Rank : %d \n" rank;
    Printf.printf "Dimension sizes : ";
    for i = 0 to rank - 1 do
      Printf.printf "%d " sdim.(i)
    done;
    Printf.printf "\n"
  end;

  if H5t.Class.FLOAT = H5t.get_class atype then begin
    Printf.printf "Type : FLOAT \n";
    let npoints = H5s.get_simple_extent_npoints aspace in
    let float_array = Array1.create float32 c_layout npoints in
    H5a.read attr atype (genarray_of_array1 float_array);
    Printf.printf "Values : ";
    for i = 0 to npoints - 1 do
      Printf.printf "%f " float_array.{i}
    done;
    Printf.printf "\n"
  end;

  H5t.close atype;
  H5s.close aspace;
  H5a.close attr;
  H5.Iter.CONT

let () =
  let matrix = Array2.create float32 c_layout _ADIM1 _ADIM2 in
  let string_out = Array1.create char c_layout 80 in
  let point_out = Array1.of_array int32 c_layout [| 1l |] in
  let vector = Array1.of_array int32 c_layout [| 1l; 2l; 3l; 4l; 5l; 6l; 7l |] in
  let point = Array1.of_array int32 c_layout [| 1l |] in
  let string_ = Array1.of_array char c_layout [| 'A'; 'B'; 'C'; 'D' |] in
  
  for i = 0 to _ADIM1 - 1 do
    for j = 0 to _ADIM2 - 1 do
      matrix.{i, j} <- -1.
    done
  done;

  let file = H5f.create _FILE H5f.Acc.([ TRUNC ]) in
  let fid = H5s.create H5s.Class.SIMPLE in
  H5s.set_extent_simple fid [| _SIZE |];
  let dataset = H5d.create file "Dataset" H5t.native_int fid in
  H5d.write dataset H5t.native_int H5s.all H5s.all (genarray_of_array1 vector);
  let aid1 = H5s.create H5s.Class.SIMPLE in
  H5s.set_extent_simple aid1 [| _ADIM1; _ADIM2 |];
  let attr1 = H5a.create dataset _ANAME H5t.native_float aid1 in
  H5a.write attr1 H5t.native_float (genarray_of_array2 matrix);
  let aid2 = H5s.create H5s.Class.SCALAR in
  let attr2 = H5a.create dataset "Integer attribute" H5t.native_int aid2 in
  H5a.write attr2 H5t.native_int (genarray_of_array1 point);
  let aid3 = H5s.create H5s.Class.SCALAR in
  let atype = H5t.copy H5t.c_s1 in
  H5t.set_size atype 4;
  let attr3 = H5a.create dataset _ANAMES atype aid3 in
  H5a.write attr3 atype (genarray_of_array1 string_);
  H5s.close aid1;
  H5s.close aid2;
  H5s.close aid3;
  H5s.close fid;
  H5a.close attr1;
  H5a.close attr2;
  H5a.close attr3;
  H5d.close dataset;
  H5f.close file;

  let file = H5f.open_ _FILE H5f.Acc.([ RDONLY ]) in
  let dataset = H5d.open_ file "Dataset" in
  let attr = H5a.open_name dataset "Integer attribute" in
  H5a.read attr H5t.native_int (genarray_of_array1 point_out);
  Printf.printf "The value of the attribute \"Integer attribute\" is %ld \n"
    point_out.{0};
  H5a.close attr;

  let attr = H5a.open_idx dataset 2 in
  let atype = H5t.copy H5t.c_s1 in
  H5t.set_size atype 4;
  H5a.read attr atype (genarray_of_array1 string_out);
  Printf.printf "The value of the attribute with the index 2 is %s \n"
    (array1_to_string string_out);
  H5a.close attr;
  H5t.close atype;

  let _ = H5a.iterate dataset attr_info () in
  H5d.close dataset;
  H5f.close file
