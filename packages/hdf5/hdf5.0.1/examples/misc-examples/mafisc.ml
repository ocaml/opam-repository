open Bigarray
open Hdf5_raw

let () =
  let dim1 = 1024 in
  let dim2 = 16 in
  let data = Array2.create Float64 C_layout dim1 dim2 in
  for i = 0 to dim1 - 1 do
    for j = 0 to dim2 - 1 do
      data.{i, j} <- float_of_int i /. float_of_int (j + 1)
    done
  done;

  Printf.printf "MAFISC avail %B\n%!" (H5z.filter_avail (H5z.Filter.CUSTOM 305));
  Printf.printf "MAFISC avail %B\n%!" (H5z.filter_avail (H5z.Filter.CUSTOM 32002));

  let file = H5f.create "mafisc-raw.h5" H5f.Acc.([ TRUNC ]) in
  let dataspace = H5s.create_simple [| dim1; dim2 |] in
  let dataset = H5d.create file "data" H5t.native_double dataspace in
  H5d.write dataset H5t.native_double H5s.all H5s.all data;
  H5d.close dataset;
  H5s.close dataspace;
  H5f.close file;

  let file = H5f.create "mafisc-compressed.h5" H5f.Acc.([ TRUNC ]) in
  let dataspace = H5s.create_simple [| dim1; dim2 |] in
  let dcpl = H5p.create H5p.Cls_id.DATASET_CREATE in
  H5p.set_filter dcpl (H5z.Filter.CUSTOM 32002) H5z.Flag.([ MANDATORY ]) [| 6 |];
  H5p.set_chunk dcpl [| dim1; dim2 |];
  let dataset = H5d.create file "data" H5t.native_double ~dcpl dataspace in
  H5d.write dataset H5t.native_double H5s.all H5s.all data;
  H5d.close dataset;
  H5s.close dataspace;
  H5f.close file
