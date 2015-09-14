The library implements most functionality needed for reading and writing HDF5 files.  It
is actively maintained.

Also provided is a fast way of working with large arrays of records.  It is much faster
than OCaml arrays of records, see `examples/bench/bench_struct.ml`.

# Building

    ./configure
    make

# lib/caml - simplified HDF5 wrapper

## Store an array

```ocaml
open Hdf5_caml

let () =
  let a = [| 0.; 1.; 2. |] in

  let output = H5.create_trunc "file.h5" in
  H5.write_float_array output "a" a;
  H5.close output;

  let input = H5.open_rdonly "file.h5" in
  let b = H5.read_float_array "a" in
  H5.close input;

  assert (a = b)
```

## Store a table

```ocaml
open Hdf5_caml

module Temperature = struct
  [%%h5struct
    time      "Time"      Int;
    latitude  "Latitude"  Float;
    longitude "Longitude" Float;
    temp      "Temp"      Float]
end

let () =
  let a = Record.Vector.create () in
  Record.(set (Vector.append a) ~time:10 ~latitude:45.2 ~longitude:0.2 ~temp:15.3);
  Record.(set (Vector.append a) ~time:11 ~latitude:45.2 ~longitude:0.2 ~temp:15.5);
  Record.(set (Vector.append a) ~time:12 ~latitude:45.3 ~longitude:0.5 ~temp:16.2);
  let a = Record.Vector.to_array a in

  let output = H5.create_trunc "file.h5" in
  Record.Array.make_table a output "Temperature";
  H5.close output
```

# lib/raw - raw HDF5 wrapper

```ocaml
open Bigarray
open Hdf5_raw

let _FILE        = "SDS.h5"
let _DATASETNAME = "IntArray"
let _NX          = 5
let _NY          = 6

let () =
  let data = Array2.create int32 c_layout _NX _NY in
  for j = 0 to _NX - 1 do
    for i = 0 to _NY - 1 do
      data.{j, i} <- Int32.of_int (i + j)
    done
  done;
  let file = H5f.create _FILE [ H5f.Acc.TRUNC ] in
  let dataspace = H5s.create_simple [| _NX; _NY |] in
  let datatype = H5t.copy H5t.native_int in
  H5t.set_order datatype H5t.Order.LE;
  let dataset = H5d.create file _DATASETNAME datatype dataspace in
  H5d.write dataset H5t.native_int H5s.all H5s.all (genarray_of_array2 data);
  H5t.close datatype;
  H5d.close dataset;
  H5s.close dataspace;
  H5f.close file
```
