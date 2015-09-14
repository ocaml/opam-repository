open Hdf5_raw
open Hdf5_caml

module H5 = H5caml

module Record = struct
  [%%h5struct
    f64 "F64" Float64;
    i   "I"   Int;
    i64 "I64" Int64;
    s   "S"   (String 16)]
end

let _LEN  = 31
let _FILE = "h5tb.h5"
let _DATA = "records"

let () =
  let data = Record.Array.init _LEN (fun i e ->
    Record.set e ~f64:(float_of_int i) ~i ~i64:(Int64.of_int i) ~s:(string_of_int i)) in
  let file = H5.create_trunc _FILE in
  Record.Array.make_table data file _DATA;
  H5.close file;

  let file = H5.open_rdwr _FILE in
  let data = Record.Array.read_table file _DATA in
  assert (Record.Array.length data = _LEN);
  assert (H5tb.get_table_info (H5.hid file) _DATA = _LEN);
  Record.Array.iteri data ~f:(fun i e ->
    assert (Record.f64 e = float_of_int i);
    assert (Record.i   e = i);
    assert (Record.i64 e = Int64.of_int i);
    assert (Record.s   e = string_of_int i));
  let new_data = Record.Array.init _LEN (fun i e ->
    let i = i + _LEN in
    Record.set e ~f64:(float_of_int i) ~i ~i64:(Int64.of_int i) ~s:(string_of_int i)) in
  Record.Array.append_records new_data file _DATA;
  H5.close file;

  let file = H5.open_rdwr _FILE in
  let data = Record.Array.read_table file _DATA in
  assert (Record.Array.length data = _LEN * 2);
  assert (H5tb.get_table_info (H5.hid file) _DATA = _LEN * 2);
  Record.Array.iteri data ~f:(fun i e ->
    assert (Record.f64 e = float_of_int i);
    assert (Record.i   e = i);
    assert (Record.i64 e = Int64.of_int i);
    assert (Record.s   e = string_of_int i));
  let new_data = Record.Array.init _LEN (fun i e ->
    Record.set e ~f64:(float_of_int i) ~i ~i64:(Int64.of_int i) ~s:(string_of_int i)) in
  Record.Array.write_records new_data file ~start:(_LEN / 2) _DATA;
  H5.close file;

  let file = H5.open_rdwr _FILE in
  let data = Record.Array.read_table file _DATA in
  assert (Record.Array.length data = _LEN * 2);
  assert (H5tb.get_table_info (H5.hid file) _DATA = _LEN * 2);
  let field_info = H5tb.get_field_info (H5.hid file) _DATA in
  assert (field_info.H5tb.Field_info.field_names = [| "F64"; "I"; "I64"; "S" |]);
  assert (field_info.H5tb.Field_info.field_sizes = [| 8; 8; 8; 16 |]);
  assert (field_info.H5tb.Field_info.field_offsets = [| 0; 8; 16; 24 |]);
  assert (field_info.H5tb.Field_info.type_size = 40);
  Record.Array.iteri data ~f:(fun i e ->
    let i =
      if i < _LEN / 2 then i
      else if i < _LEN / 2 + _LEN then i - _LEN / 2
      else i
    in
    assert (Record.f64 e = float_of_int i);
    assert (Record.i   e = i);
    assert (Record.i64 e = Int64.of_int i);
    assert (Record.s   e = string_of_int i));

  let data = Record.Array.read_records file ~start:(_LEN / 2) ~nrecords:_LEN _DATA in
  Record.Array.iteri data ~f:(fun i e ->
    assert (Record.f64 e = float_of_int i);
    assert (Record.i   e = i);
    assert (Record.i64 e = Int64.of_int i);
    assert (Record.s   e = string_of_int i));
  H5.close file;
