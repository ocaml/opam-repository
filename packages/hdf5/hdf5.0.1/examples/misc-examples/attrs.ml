open Bigarray
open Hdf5_raw

let _H5FILE_NAME = "Attributes.h5"
let _SIZE  = 7
let _ADIM1 = 2
let _ADIM2 = 3
let _ANAME = "Float attribute"
let _ANAMES = "Character attribute"

let attr_info loc_id name _ () =
  let attr = H5a.open_name loc_id name in
  Printf.printf "\nName : %s\n" name;

  let atype = H5a.get_type attr in
  let aspace = H5a.get_space attr in
  let sdim, _ = H5s.get_simple_extent_dims aspace in
  let rank = Array.length sdim in
  let class_ = H5s.get_simple_extent_type aspace in
  Printf.printf "H5Sget_simple_extent_type (aspace) returns %i\n"
    ( match class_ with
      | H5s.Class.SCALAR -> 1
      | H5s.Class.SIMPLE -> 2
      | H5s.Class.NULL -> 3 );

  if rank > 0 then begin
    Printf.printf "Rank : %d \n" rank;
    Printf.printf "Dimension sizes : ";
    for i = 0 to rank - 1 do
      Printf.printf "%d " sdim.(i)
    done;
    Printf.printf "\n"
  end;

  begin match H5t.get_class atype with
  | H5t.Class.INTEGER ->
    Printf.printf "Type : INTEGER \n";
    let point_out = 0l in
    H5a.read attr atype point_out;
    Printf.printf "The value of the attribute \"Integer attribute\" is %ld \n" point_out
  | H5t.Class.FLOAT ->
    Printf.printf "Type : FLOAT \n";
    let npoints = H5s.get_simple_extent_npoints aspace in
    let float_array = Array1.create Float32 C_layout npoints in
    H5a.read attr atype float_array;
    Printf.printf "Values : ";
    for i = 0 to npoints - 1 do
      Printf.printf "%f " float_array.{i}
    done;
    Printf.printf "\n"
  | H5t.Class.STRING ->
    Printf.printf "Type : STRING \n";
    let size = H5t.get_size atype in
    Printf.printf "Size of Each String is: %i\n" size;
    let totsize = size * sdim.(0) * sdim.(1) in
    let string_out = Bytes.create totsize in
    H5a.read attr atype string_out;
    Printf.printf "The value of the attribute with index 2 is:\n";
    let j = ref 0 in
    for i = 0 to totsize - 1 do
      Printf.printf "%c" string_out.[i];
      if !j = 3 then begin
        Printf.printf " ";
        j := 0
      end else incr j
    done;
    Printf.printf "\n"
  | _ -> ()
  end;

  H5t.close atype;
  H5s.close aspace;
  H5a.close attr;

  H5.Iter.CONT

let () =
  let matrix = Array2.create Float32 C_layout _ADIM1 _ADIM2 in
  let vector = Array1.of_array Int32 C_layout [| 1l; 2l; 3l; 4l; 5l; 6l; 7l |] in
  let point = 1l in
  let string_ = "testwestvestbest" in
  for i = 0 to _ADIM1 - 1 do
    for j = 0 to _ADIM2 - 1 do
      matrix.{i, j} <- 9.9
    done
  done;

  let file = H5f.create _H5FILE_NAME H5f.Acc.([ TRUNC ]) in
  let fid = H5s.create H5s.Class.SIMPLE in
  H5s.set_extent_simple fid [| _SIZE |];
  let dataset = H5d.create file "Dataset" H5t.native_int fid in
  H5d.write dataset H5t.native_int H5s.all H5s.all vector;

  let aid1 = H5s.create H5s.Class.SIMPLE in
  H5s.set_extent_simple aid1 [| _ADIM1; _ADIM2 |];
  let attr1 = H5a.create dataset _ANAME H5t.native_float aid1 in
  H5a.write attr1 H5t.native_float matrix;

  let aid2 = H5s.create H5s.Class.SCALAR in
  let attr2 = H5a.create dataset "Integer attribute" H5t.native_int aid2 in
  H5a.write attr2 H5t.native_int point;

  let aid3 = H5s.create_simple [| 2; 2 |] in
  let atype = H5t.copy H5t.c_s1 in
  H5t.set_size atype 4;
  H5t.set_strpad atype H5t.Str.NULLTERM;
  let attr3 = H5a.create dataset _ANAMES atype aid3 in
  H5a.write attr3 atype string_;

  H5s.close aid1;
  H5s.close aid2;
  H5s.close aid3;
  H5s.close fid;
  H5a.close attr1;
  H5a.close attr2;
  H5a.close attr3;
  H5d.close dataset;
  H5f.close file;

  let file = H5f.open_ _H5FILE_NAME H5f.Acc.([ RDONLY ]) in
  let dataset = H5d.open_ file "Dataset" in

  Printf.printf "\nAttributes for 'Dataset' are:\n";
  let _ = H5a.iterate dataset attr_info () in

  H5d.close dataset;
  H5f.close file
