open Bigarray
open Hdf5_raw

type t =
| File of Hid.t
| Group of Hid.t

let hid = function
| File f -> f
| Group g -> g

let create_trunc name =
  File (H5f.create name H5f.Acc.([ TRUNC ]))

let open_rdonly name =
  File (H5f.open_ name H5f.Acc.([ RDONLY ]))

let open_rdwr name =
  File (H5f.open_ name H5f.Acc.([ CREAT; RDWR ]))

let open_dir t name =
  let t = hid t in
  Group (if name = "." || H5l.exists t name then H5g.open_ t name else H5g.create t name)

let close = function
| File f -> H5f.close f
| Group g -> H5g.close g

let flush t = H5f.flush (hid t) H5f.Scope.LOCAL

let get_name t = H5f.get_name (hid t)

let exists t name =
  H5l.exists (hid t) name

let ls t ?(index = Hdf5_raw.H5.Index.NAME) ?(order = Hdf5_raw.H5.Iter_order.NATIVE) name =
  let links = ref [] in
  let t = open_dir t name in
  let _ = H5l.iterate (hid t) index order (fun _ l _ () ->
    links := l :: !links;
    Hdf5_raw.H5.Iter.CONT) () in
  close t;
  List.rev !links

let copy ~src ~src_name ~dst ~dst_name =
  H5o.copy (hid src) src_name (hid dst) dst_name

let rec merge ~src ~dst =
  let _ = H5l.iterate src Hdf5_raw.H5.Index.NAME Hdf5_raw.H5.Iter_order.NATIVE
    (fun _ name _ () ->
      if H5l.exists dst name then begin
        let src = H5o.open_ src name in
        let dst = H5o.open_ dst name in
        begin match H5i.get_type src, H5i.get_type dst with
        | t, t' when t <> t' ->
          invalid_arg (Printf.sprintf
            "Object %s not of the same type in source and destination" name)
        | H5i.Type.FILE, _
        | H5i.Type.GROUP, _ -> merge ~src ~dst
        | H5i.Type.DATASET, _ -> ()
        | H5i.Type.DATATYPE, _
        | H5i.Type.DATASPACE, _
        | H5i.Type.ATTR, _
        | H5i.Type.REFERENCE, _
        | H5i.Type.VFL, _
        | H5i.Type.GENPROP_CLS, _
        | H5i.Type.GENPROP_LST, _
        | H5i.Type.ERROR_CLASS, _
        | H5i.Type.ERROR_MSG, _
        | H5i.Type.ERROR_STACK, _
        | H5i.Type.NTYPES, _ ->
          invalid_arg (Printf.sprintf "Unhandled object type %d for the object %s"
            (Obj.magic (H5i.get_type src)) name)
        end;
        H5o.close src;
        H5o.close dst
      end else H5o.copy src name dst name;
      Hdf5_raw.H5.Iter.CONT
    ) () in ()

let merge ~src ~dst = merge ~src:(hid src) ~dst:(hid dst)

let write_data t datatype dims name ?(deflate = 6) data =
  let dataspace = H5s.create_simple dims in
  let dcpl =
    match deflate with
    | 0 -> None
    | deflate ->
      let dcpl = H5p.create H5p.Cls_id.DATASET_CREATE in
      H5p.set_chunk dcpl dims;
      H5p.set_deflate dcpl deflate;
      Some dcpl
  in
  let dataset = H5d.create (hid t) name datatype ?dcpl dataspace in
  H5d.write dataset datatype H5s.all H5s.all data;
  H5d.close dataset;
  H5s.close dataspace;
  match dcpl with
  | None -> ()
  | Some dcpl -> H5p.close dcpl

let read_data expected_datatype create verify t data name =
  let hid = hid t in
  let dataset = H5d.open_ hid name in
  let datatype = H5d.get_type dataset in
  if not (H5t.equal expected_datatype datatype) then
    invalid_arg "Unexpected datatype";
  let dataspace = H5d.get_space dataset in
  let dims, _ = H5s.get_simple_extent_dims dataspace in
  let data =
    match data with
    | Some data -> verify (Obj.magic data) dims
    | None -> Obj.magic (create dims) in
  H5d.read dataset datatype H5s.all H5s.all data;
  H5s.close dataspace;
  H5t.close datatype;
  H5d.close dataset;
  Obj.magic data

let write_float_array t name ?deflate (a : float array) =
  write_data t H5t.native_double [| Array.length a |] name ?deflate a

let write_float_array1 t name ?deflate (a : (float, float64_elt, _) Array1.t) =
  write_data t H5t.native_double [| Array1.dim a |] name ?deflate a

let write_float_array2 t name ?deflate (a : (float, float64_elt, _) Array2.t) =
  write_data t H5t.native_double [| Array2.dim1 a; Array2.dim2 a |] name ?deflate a

let write_uint8_array1 t name ?deflate (a : (char, int8_unsigned_elt, _) Array1.t)
  = write_data t H5t.native_b8 [| Array1.dim a |] name ?deflate a

let read_float_array t ?data name = read_data H5t.native_double
  (fun dims ->
    if Array.length dims <> 1 then invalid_arg "Dataset not one dimensional";
    Array.make_float dims.(0))
  (fun data dims ->
    if Array.length dims <> 1 then invalid_arg "Dataset not one dimensional";
    if Array.length data < dims.(0) then
      invalid_arg "The provided data storage too small";
    data)
  t data name

let read_float_array1 t ?data name = read_data H5t.native_double
  (fun dims ->
    if Array.length dims <> 1 then invalid_arg "Dataset not one dimensional";
    Array1.create Float64 C_layout dims.(0))
  (fun data dims ->
    if Array.length dims <> 1 then invalid_arg "Dataset not one dimensional";
    if Array1.dim data < dims.(0) then
      invalid_arg "The provided data storage too small";
    data)
  t data name

let read_float_array2 t ?data name = read_data H5t.native_double
  (fun dims ->
    if Array.length dims <> 2 then invalid_arg "Dataset not two dimensional";
    Array2.create Float64 C_layout dims.(0) dims.(1))
  (fun data dims ->
    if Array.length dims <> 2 then invalid_arg "Dataset not two dimensional";
    if Array2.dim2 data <> dims.(1) then
      invalid_arg "Dim2 of the provided data has wrong size";
    if Array2.dim1 data < dims.(0) then
      invalid_arg "The provided data storage too small";
    data)
  t data name

let read_uint8_array1 t ?data name = read_data H5t.native_b8
  (fun dims ->
    if Array.length dims <> 1 then invalid_arg "Dataset not one dimensional";
    Array1.create Char C_layout dims.(0))
  (fun data dims ->
    if Array.length dims <> 1 then invalid_arg "Dataset not one dimensional";
    if Array1.dim data < dims.(0) then
      invalid_arg "The provided data storage too small";
    data)
  t data name

let write_float_array_array t name ?(transpose = true) ?deflate (a : float array array) =
  let dim1 = Array.length a in
  if dim1 = 0 then invalid_arg "Empty array";
  let e = Obj.repr a.(0) in
  let dim2 = Obj.size e in
  write_float_array2 t name ?deflate (
    if transpose then begin
      let a' = Array2.create Float64 C_layout dim2 dim1 in
      for i = 0 to dim1 - 1 do
        let e = Obj.repr (Array.unsafe_get a i) in
        if Obj.tag e <> Obj.double_array_tag then
          invalid_arg "All elements not float array";
        if Obj.size e <> dim2 then invalid_arg "All elements not of the same size";
        for j = 0 to dim2 - 1 do
          Array2.set a' j i (Obj.double_field e j)
        done
      done;
      a'
    end else begin
      let a' = Array2.create Float64 C_layout dim1 dim2 in
      for i = 0 to dim1 - 1 do
        let e = Obj.repr (Array.unsafe_get a i) in
        if Obj.tag e <> Obj.double_array_tag then
          invalid_arg "All elements not float array";
        if Obj.size e <> dim2 then invalid_arg "All elements not of the same size";
        for j = 0 to dim2 - 1 do
          Array2.set a' i j (Obj.double_field e j)
        done
      done;
      a'
    end)

let read_float_array_array t ?(transpose = true) name =
  let a = read_float_array2 t name in
  let dim1 = Array2.dim2 a in
  let dim2 = Array2.dim1 a in
  if transpose then begin
    Array.init dim1 (fun i ->
      let e = Array.make_float dim2 in
      for j = 0 to dim2 - 1 do
        Array.set e j (Array2.get a j i)
      done;
      e)
  end else begin
    Array.init dim1 (fun i ->
      let e = Array.make_float dim2 in
      for j = 0 to dim2 - 1 do
        Array.set e j (Array2.get a i j)
      done;
      e)
  end

let write_attribute_string_array t dataset_name attribute_name (a : string array) =
  let datatype = H5t.copy H5t.c_s1 in
  H5t.set_size datatype H5t.variable; 
  let dataspace = H5s.create_simple [| Array.length a |] in
  let dataset = H5d.open_ (hid t) dataset_name in
  let att = H5a.create dataset attribute_name datatype dataspace in
  H5a.write att datatype a;
  H5a.close att;
  H5d.close dataset;
  H5s.close dataspace;
  H5t.close datatype

let read_attribute_string_array t dataset_name attribute_name =
  let dataset = H5d.open_ (hid t) dataset_name in
  let att = H5a.open_ dataset attribute_name in
  let dataspace = H5a.get_space att in
  let datatype = H5a.get_type att in
  let dims, _ = H5s.get_simple_extent_dims dataspace in
  let a = Array.make dims.(0) "" in
  H5a.read_vl att datatype a;
  H5t.close datatype;
  H5s.close dataspace;
  H5a.close att;
  H5d.close dataset;
  a
