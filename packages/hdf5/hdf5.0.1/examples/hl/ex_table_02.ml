open Hdf5_raw
open Hdf5_caml

let _NRECORDS     = 8
let _NRECORDS_ADD = 2
let _TABLE_NAME   = "table"

module Particle = struct
  [%%h5struct
    name        "Name"        (String 16);
    lati        "Latitude"    Int;
    longi       "Longitude"   Int;
    pressure    "Pressure"    Float64;
    temperature "Temperature" Float64]
end

let () =
  let dst_buf = Particle.Array.make (_NRECORDS + _NRECORDS_ADD) in
  let p_data = Particle.Vector.create () in
  Particle.(set (Vector.append p_data) ~name:"zero"  ~lati: 0 ~longi: 0 ~pressure:0. ~temperature: 0.);
  Particle.(set (Vector.append p_data) ~name:"one"   ~lati:10 ~longi:10 ~pressure:1. ~temperature:10.);
  Particle.(set (Vector.append p_data) ~name:"two"   ~lati:20 ~longi:20 ~pressure:2. ~temperature:20.);
  Particle.(set (Vector.append p_data) ~name:"three" ~lati:30 ~longi:30 ~pressure:3. ~temperature:30.);
  Particle.(set (Vector.append p_data) ~name:"four"  ~lati:40 ~longi:40 ~pressure:4. ~temperature:40.);
  Particle.(set (Vector.append p_data) ~name:"five"  ~lati:50 ~longi:50 ~pressure:5. ~temperature:50.);
  Particle.(set (Vector.append p_data) ~name:"six"   ~lati:60 ~longi:60 ~pressure:6. ~temperature:60.);
  Particle.(set (Vector.append p_data) ~name:"seven" ~lati:70 ~longi:70 ~pressure:7. ~temperature:70.);
  let p_data = Particle.Vector.to_array p_data in

  let particle_in = Particle.Vector.create () in
  Particle.(set (Vector.append particle_in) ~name:"eight" ~lati:80 ~longi:80 ~pressure:8. ~temperature:80.);
  Particle.(set (Vector.append particle_in) ~name:"nine"  ~lati:90 ~longi:90 ~pressure:9. ~temperature:90.);
  let particle_in = Particle.Vector.to_array particle_in in

  let string_type = H5t.copy H5t.c_s1 in
  H5t.set_size string_type 16;
  let file_id = H5f.create "ex_table_02.h5" H5f.Acc.([ TRUNC ]) in
  H5tb.make_table "Table Title" file_id _TABLE_NAME ~nrecords:_NRECORDS
    ~type_size:Particle.size
    ~field_names:[| "Name"; "Latitude"; "Longitude"; "Pressure"; "Temperature" |]
    ~field_offset:[| 0; 16; 24; 32; 40 |]
    ~field_types:[|
      string_type; H5t.native_long; H5t.native_long; H5t.native_double; H5t.native_double
    |]
    ~chunk_size:10
    ~compress:false
    p_data;
  H5tb.append_records file_id _TABLE_NAME ~nrecords:_NRECORDS_ADD ~type_size:Particle.size
    ~field_offset:[| 0; 16; 24; 32; 40 |]
    ~field_sizes:[| 16; 8; 8; 8; 8 |]
    particle_in;
  H5tb.read_table file_id _TABLE_NAME ~dst_size:Particle.size
    ~dst_offset:[| 0; 16; 24; 32; 40 |]
    ~dst_sizes:[| 16; 8; 8; 8; 8 |]
    dst_buf;
  let p = Particle.Array.unsafe_get dst_buf 0 in
  for _ = 0 to _NRECORDS + _NRECORDS_ADD - 1 do
    Printf.printf "%-5s %-5d %-5d %-5f %-5f\n%!"
      (Particle.name p) (Particle.lati p) (Particle.longi p) (Particle.pressure p)
      (Particle.temperature p);
    Particle.unsafe_next p
  done;
  H5t.close string_type;
  H5f.close file_id
