module Type = struct
  type t =
  | Int
  | Int64
  | Float64
  | String of int

  let size = function
  | Int | Int64 | Float64 -> 8
  | String l -> l
end

module Field = struct
  type t = {
    name  : string;
    type_ : Type.t;
  }

  let create name type_ = { name; type_ }
end

module type S = sig
  val fields : Field.t list
end

module Mem = struct
  type t = {
    ops      : int;
    data     : int;
    num_dims : int;
    flags    : int;
    proxy    : int;
    dim      : int;
  }
end

module Ptr = struct
  type t = {
    mutable ptr : int;
    mem         : Mem.t;
    begin_      : int;
    end_        : int;
    mutable len : int;
    mutable i   : int;
  }

  let unsafe_next t size =
    let t = Obj.magic t in
    let ptr = t.ptr + size in
    t.ptr <- ptr

  let unsafe_prev t size =
    let t = Obj.magic t in
    let ptr = t.ptr - size in
    t.ptr <- ptr

  let unsafe_move t i size =
    let t = Obj.magic t in
    t.ptr <- t.begin_ + i * size;
    t.i <- i

  let next t size =
    let t = Obj.magic t in
    let ptr = t.ptr + size in
    if ptr > t.end_
    then raise (Invalid_argument "index out of bounds")
    else t.ptr <- ptr

  let prev t size =
    let t = Obj.magic t in
    let ptr = t.ptr - size in
    if ptr < t.begin_
    then raise (Invalid_argument "index out of bounds")
    else t.ptr <- ptr

  let move t i size =
    let t = Obj.magic t in
    let ptr = t.begin_ + i * size in
    if i < 0 || ptr > t.end_
    then raise (Invalid_argument "index out of bounds")
    else begin
      t.ptr <- ptr;
      t.i <- i
    end

  open Bigarray

  let get_float64 t i   =
    Obj.magic (Array.unsafe_get (Obj.magic (Obj.magic t).ptr : float array) i)
  let set_float64 t i v =
    Array.unsafe_set (Obj.magic (Obj.magic t).ptr : float array) i (Obj.magic v)
  let get_int t i = Obj.magic (
    Int64.to_int (Obj.magic (Obj.magic (Obj.magic t).ptr + (i - 1) * 4) : int64))
  let set_int t i v =
    let a : (int64, int64_elt, c_layout) Array1.t = Obj.magic (Obj.magic t - 4) in
    Array1.unsafe_set a i (Int64.of_int (Obj.magic v))
  let get_int64 t i =
    let a : (int64, int64_elt, c_layout) Array1.t = Obj.magic (Obj.magic t - 4) in
    Obj.magic (Array1.unsafe_get a i)
  let set_int64 t i v =
    let a : (int64, int64_elt, c_layout) Array1.t = Obj.magic (Obj.magic t - 4) in
    Array1.unsafe_set a i (Obj.magic v)

  external unsafe_fill : bytes -> int -> int -> char -> unit
                       = "caml_fill_string" "noalloc"
  external unsafe_blit_string : string -> int -> bytes -> int -> int -> unit
                       = "caml_blit_string" "noalloc"

  let get_string =
    let rec index ptr c pos l len =
      if l >= len then len
      else if String.unsafe_get ptr pos = c then l
      else index ptr c (pos + 1) (l + 1) len
    in
    fun t pos len ->
      let t = Obj.magic t in
      let len = index (Obj.magic t.ptr) '\000' pos 0 len in
      let s = Bytes.create len in
      unsafe_blit_string (Obj.magic t.ptr) pos s 0 len;
      s

  let set_string t pos len v =
    let t = Obj.magic t in
    let vlen = String.length v in
    let mlen = if len < vlen then len else vlen in
    unsafe_blit_string v 0 (Obj.magic t.ptr) pos mlen;
    unsafe_fill (Obj.magic t.ptr) (pos + mlen) (len - mlen) '\000'

  let seek_float64 t size pos ~min ~max v =
    let mid = ref min in
    let min = ref min in
    let max = ref max in
    let data = t.mem.Mem.data + pos * 4 in
    while !max > !min + 1 do
      mid := (!min + !max) asr 1;
      let v' = Array.unsafe_get (Obj.magic (data + !mid * size) : float array) 0 in
      if v' < v then
        min := !mid
      else
        max := !mid
    done;
    let v' = Array.unsafe_get (Obj.magic (data + !min * size) : float array) 0 in
    if v' >= v then !min else !max

  let seek_float64 t size pos v =
    let v : float = Obj.magic v in
    let t = Obj.magic t in
    let data = t.mem.Mem.data in
    if t.len < 0 then t.len <- t.mem.Mem.dim / size;
    let len = t.len in
    if data + t.i * size <> t.ptr then
      t.i <- (t.ptr - data) / size;
    let i = t.i in
    let pos4 = pos * 4 in
    let data = data + pos4 in
    let v' = Array.unsafe_get (Obj.magic (t.ptr + pos4) : float array) 0 in
    let min = ref i in
    let max = ref i in
    let step = ref 1 in
    if v' < v then begin
      if !max < len - 1 then begin
        incr min;
        max := !min
      end;
      while !max < len
        && Array.unsafe_get (Obj.magic (data + !max * size)) 0 < v do
        max := !max + !step;
        step := !step * 2
      done;
      if !max >= len then max := len - 1
    end else if v' > v then begin
      if !min > 0 then begin
        decr min;
        max := !min
      end;
      while !min > 0 && Array.unsafe_get (Obj.magic (data + !min * size)) 0 > v do
        min := !min - !step;
        step := !step * 2
      done;
      if !min < 0 then min := 0
    end;
    unsafe_move t (
      if !max > !min then seek_float64 t size pos ~min:!min ~max:!max v else !max) size

  let seek_int t size pos ~min ~max v =
    let mid = ref min in
    let min = ref min in
    let max = ref max in
    let data = t.mem.Mem.data + (pos - 1) * 4 in
    while !max > !min + 1 do
      mid := (!min + !max) asr 1;
      let v' = Int64.to_int (Obj.magic (data + !mid * size)) in
      if v' < v then
        min := !mid
      else
        max := !mid
    done;
    let v' = Int64.to_int (Obj.magic (data + !min * size)) in
    if v' >= v then !min else !max

  let seek_int t size pos v =
    let v : int = Obj.magic v in
    let t = Obj.magic t in
    let data = t.mem.Mem.data in
    if t.len < 0 then t.len <- t.mem.Mem.dim / size;
    let len = t.len in
    if data + t.i * size <> t.ptr then
      t.i <- (t.ptr - data) / size;
    let i = t.i in
    let pos4 = pos * 4 in
    let data = data + pos4 in
    let v' = Int64.to_int (Obj.magic (t.ptr + pos4)) in
    let min = ref i in
    let max = ref i in
    let step = ref 1 in
    if v' < v then begin
      if !max < len - 1 then begin
        incr min;
        max := !min
      end;
      while !max < len && Int64.to_int (Obj.magic (data + !max * size)) < v do
        max := !max + !step;
        step := !step * 2
      done;
      if !max >= len then max := len - 1
    end else if v' > v then begin
      if !min > 0 then begin
        decr min;
        max := !min
      end;
      while !min > 0 && Int64.to_int (Obj.magic (data + !min * size)) > v do
        min := !min - !step;
        step := !step * 2
      done;
      if !min < 0 then min := 0
    end;
    unsafe_move t (
      if !max > !min then seek_int t size pos ~min:!min ~max:!max v else !max) size

  let seek_int64 t size pos ~min ~max (v : int64) =
    let mid = ref min in
    let min = ref min in
    let max = ref max in
    let data = t.mem.Mem.data + pos * 4 - 4 in
    while !max > !min + 1 do
      mid := (!min + !max) asr 1;
      let v' = Obj.magic (data + !mid * size) in
      if v' < v then
        min := !mid
      else
        max := !mid
    done;
    let v' = Obj.magic (data + !min * size) in
    if v' >= v then !min else !max

  let seek_int64 t size pos v =
    let v : int64 = Obj.magic v in
    let t = Obj.magic t in
    let data = t.mem.Mem.data in
    if t.len < 0 then t.len <- t.mem.Mem.dim / size;
    let len = t.len in
    if data + t.i * size <> t.ptr then
      t.i <- (t.ptr - data) / size;
    let i = t.i in
    let data = data + pos * 4 - 4 in
    let v' = Obj.magic (data + i * size) in
    let min = ref i in
    let max = ref i in
    let step = ref 1 in
    if v' < v then begin
      if !max < len - 1 then begin
        incr min;
        max := !min
      end;
      while !max < len && Obj.magic (data + !max * size) < v do
        max := !max + !step;
        step := !step * 2
      done;
      if !max >= len then max := len - 1
    end else if v' > v then begin
      if !min > 0 then begin
        decr min;
        max := !min
      end;
      while !min > 0 && Obj.magic (data + !min * size) > v do
        min := !min - !step;
        step := !step * 2
      done;
      if !min < 0 then min := 0
    end;
    unsafe_move t (
      if !max > !min then seek_int64 t size pos ~min:!min ~max:!max v else !max) size

  let seek_string _t _size _pos _len _v =
    failwith "[seek_string] not implemented"
end

module Make(S : S) = struct
  include S

  let nfields = List.length S.fields
  let size64 = List.fold_left (fun s field ->
    s + (Type.size field.Field.type_ + 7) / 8 * 8 / 2) 0 S.fields
  let size = 2 * size64
  let field_names =
    List.map (fun field -> field.Field.name) S.fields
    |> Array.of_list
  let field_offset =
    let offset = ref 0 in
    List.map (fun field ->
      let field_offset = !offset in
      offset := !offset + (Type.size field.Field.type_ + 7) / 8 * 8;
      field_offset) S.fields
    |> Array.of_list
  let field_types =
    let module H5t = Hdf5_raw.H5t in
    List.map (fun field ->
      match field.Field.type_ with
      | Type.Int | Type.Int64 -> H5t.native_long
      | Type.Float64 -> H5t.native_double
      | Type.String l ->
        let type_ = H5t.copy H5t.c_s1 in
        H5t.set_size type_ l;
        type_) S.fields
    |> Array.of_list
  let field_sizes =
    List.map (fun field -> Type.size field.Field.type_) S.fields
    |> Array.of_list

  include Ptr

  open Bigarray

  let pos t = t.Ptr.i
  let has_next t = t.Ptr.ptr + size64 < t.Ptr.end_
  let has_prev t = t.Ptr.i > 0
  let unsafe_next t = Ptr.unsafe_next t size64
  let unsafe_move t i = Ptr.unsafe_move t i size64 

  module Array = struct
    type e = t
    type t = Mem.t

    let make len = (Obj.magic (Array1.create Char C_layout (len * size)) : Mem.t)

    let length t = t.Mem.dim / size64

    let unsafe_get t i =
      let data = t.Mem.data in
      { ptr = data + i * size64; mem = t; begin_ = data; end_ = data + t.Mem.dim;
        len = -1; i }

    let init len f =
      let t = make len in
      let e = unsafe_get t 0 in
      for i = 0 to len - 2 do
        f i e;
        unsafe_next e
      done;
      f (len - 1) e;
      t

    let get t i =
      let ptr = t.Mem.data + i * size64 in
      let data = t.Mem.data in
      if i < 0 || ptr > data + t.Mem.dim then
        raise (Invalid_argument "index out of bounds");
      { ptr; mem = t; begin_ = data; end_ = data + t.Mem.dim; len = -1; i }

    let unsafe_blit t t' = Array2.blit (Obj.magic t) (Obj.magic t')

    module H5tb = Hdf5_raw.H5tb

    let make_table t ?title ?chunk_size ?(compress = true) h5
        dset_name =
      let title = match title with Some t -> t | None -> dset_name in
      let chunk_size = match chunk_size with Some s -> s | None -> length t in
      H5tb.make_table title (H5caml.hid h5) dset_name ~nrecords:(t.Mem.dim / size64)
        ~type_size:size ~field_names ~field_offset ~field_types ~chunk_size ~compress t

    let append_records t h5 dset_name =
      H5tb.append_records (H5caml.hid h5) dset_name ~nrecords:(t.Mem.dim / size64)
        ~type_size:size ~field_offset ~field_sizes t

    let write_records t h5 ~start dset_name =
      H5tb.write_records (H5caml.hid h5) dset_name ~start ~nrecords:(t.Mem.dim / size64)
        ~type_size:size ~field_offset ~field_sizes t

    let read_table h5 table_name =
      let loc = H5caml.hid h5 in
      let nrecords = H5tb.get_table_info loc table_name in
      let t = make nrecords in
      H5tb.read_table loc table_name ~dst_size:size ~dst_offset:field_offset
        ~dst_sizes:field_sizes t;
      t

    let read_records h5 ~start ~nrecords table_name =
      let loc = H5caml.hid h5 in
      let t = make nrecords in
      H5tb.read_records loc table_name ~start ~nrecords ~type_size:size ~field_offset
        ~dst_sizes:field_sizes t;
      t

    let iter t ~f =
      let e = unsafe_get t 0 in
      for _ = 0 to length t - 1 do
        f e;
        unsafe_next e
      done

    let iteri t ~f =
      let e = unsafe_get t 0 in
      for i = 0 to length t - 1 do
        f i e;
        unsafe_next e
      done
  end

  let create () = Array.unsafe_get (Array.make 1) 0
  let mem t = t.mem

  module Vector = struct
    type e = t
    type t = {
      mutable mem : Mem.t;
      mutable capacity : int;
      mutable length : int;
      mutable end_ : e;
    }

    let create ?(capacity = 16) () =
      let mem = Array.make capacity in
      { mem; capacity; length = 0; end_ = Array.unsafe_get mem (-1) }

    let resize t capacity =
      if t.capacity > capacity then begin
        let mem = Array.make capacity in
        Array.unsafe_blit (Array1.sub (Obj.magic t.mem) 0 (capacity * size))
          (Obj.magic mem);
        t.mem <- mem
      end else if t.capacity < capacity then begin
        let mem = Array.make capacity in
        Array.unsafe_blit (Obj.magic t.mem)
          (Array1.sub (Obj.magic mem) 0 (t.capacity * size));
        t.mem <- mem
      end;
      t.capacity <- capacity

    let append t =
      if t.capacity = t.length then begin
        resize t (t.capacity * 2);
        t.end_ <- Array.unsafe_get t.mem (t.length - 1)
      end;
      t.length <- t.length + 1;
      unsafe_next t.end_;
      t.end_

    let unsafe_get (t : t) i = Array.unsafe_get t.mem i

    let iter (t : t) ~f =
      let ptr = t.end_ in
      unsafe_move ptr 0;
      for _ = 0 to t.length - 1 do
        f ptr;
        unsafe_next ptr
      done;
      unsafe_move ptr t.length

    let of_array a =
      let len = Array.length a in
      { mem = a; capacity = len; length = len; end_ = Array.unsafe_get a (len - 1) }

    let to_array t =
      let mem = Array.make t.length in
      Array.unsafe_blit (Array1.sub (Obj.magic t.mem) 0 (t.length * size)) mem;
      (Obj.magic mem : Mem.t)
  end
end
