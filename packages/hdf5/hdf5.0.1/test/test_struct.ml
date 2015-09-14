module Record = struct
  [%%h5struct
    sf64 "sf64" Float64     Seek;
    si   "si"   Int         Seek;
    si64 "si64" Int64       Seek;
    ss   "ss"   (String 14) Seek;
    f64  "f64"  Float64;
    i    "i"    Int;
    i64  "i64"  Int64;
    s    "s"    (String 16)]
end

let () =
  let len = 1000 in
  let a = Record.Array.init len (fun i e ->
    let f = float_of_int i in
    let i64 = Int64.of_int i in
    let s = string_of_int i in
    Record.set e ~sf64:f ~si:i ~si64:i64 ~ss:s ~f64:f ~i ~i64 ~s) in
  let expected_val e i =
    let f   = float_of_int  i in
    let i64 = Int64.of_int  i in
    let s   = string_of_int i in
       Record.sf64 e = f  
    && Record.si   e = i  
    && Record.si64 e = i64
    && Record.ss   e = s  
    && Record.f64  e = f  
    && Record.i    e = i  
    && Record.i64  e = i64
    && Record.s    e = s  
  in
  for i = 0 to len - 1 do
    let e = Record.Array.get a i in
    assert (expected_val e i)
  done;
  let e = Record.Array.get a 0 in
  for i = 0 to len - 2 do
    assert (expected_val e i);
    Record.next e
  done;
  assert (expected_val e (len - 1));
  for i = len - 1 downto 1 do
    assert (expected_val e i);
    Record.prev e
  done;
  assert (expected_val e 0);
  for i = 0 to len - 1 do
    Record.move e i;
    assert (expected_val e i)
  done;

  let r = Array.init len (fun i -> i) in
  for i = 0 to len - 2 do
    let j = i + Random.int (len - i) in
    let r_i = r.(i) in
    r.(i) <- r.(j);
    r.(j) <- r_i
  done;

  for i = 0 to len - 1 do
    Record.seek_sf64 e (float_of_int r.(i));
    assert (expected_val e r.(i))
  done;
  for i = 0 to len - 1 do
    Record.seek_si e r.(i);
    assert (expected_val e r.(i))
  done;
  for i = 0 to len - 1 do
    Record.seek_si64 e (Int64.of_int r.(i));
    assert (expected_val e r.(i))
  done;
