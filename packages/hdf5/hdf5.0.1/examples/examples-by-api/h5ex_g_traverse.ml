open Hdf5_raw

let _FILE = "h5ex_g_traverse.h5"

module Opdata = struct
  type t = {
    mutable recurs : int;
    mutable prev   : t option;
    mutable addr   : int;
  }
end

let rec group_check od target_addr =
  if od.Opdata.addr = target_addr then true
  else
    match od.Opdata.prev with
    | None -> false
    | Some prev -> group_check prev target_addr

let rec op_func loc_id name _info od =
  let return_val = ref H5.Iter.CONT in
  let spaces = 2 * (od.Opdata.recurs + 1) in
  let infobuf = H5o.get_info_by_name loc_id name in
  Printf.printf "%*s" spaces "";
  begin match infobuf.H5o.Info.type_ with
  | H5o.Type.GROUP ->
    Printf.printf "Group: %s {\n%!" name;
    if group_check od infobuf.H5o.Info.addr then
      Printf.printf "%*s  Warning: Loop detected!\n%!" spaces ""
    else begin
      let nextod = { Opdata.
        recurs = od.Opdata.recurs + 1;
        prev = Some od;
        addr = infobuf.H5o.Info.addr } in
      return_val :=
        H5l.iterate_by_name loc_id name H5.Index.NAME H5.Iter_order.NATIVE op_func nextod
    end;
    Printf.printf "%*s}\n%!" spaces ""
  | H5o.Type.DATASET ->
    Printf.printf "Dataset: %s\n%!" name
  | H5o.Type.NAMED_DATATYPE ->
    Printf.printf "Datatype: %s\n%!" name
  | H5o.Type.NTYPES ->
    Printf.printf "Unknown: %s\n%!" name
  end;
  !return_val

let () =
  let file = H5f.open_ _FILE H5f.Acc.([ RDONLY ]) in
  let infobuf = H5o.get_info file in
  let od = { Opdata.recurs = 0; prev = None; addr = infobuf.H5o.Info.addr } in

  Printf.printf "/ {\n%!";
  let _ = H5l.iterate file H5.Index.NAME H5.Iter_order.NATIVE op_func od in
  Printf.printf "}\n%!";

  H5f.close file 
