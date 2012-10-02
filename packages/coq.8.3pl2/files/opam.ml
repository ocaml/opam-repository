
module type COMMAND = sig
  val s_title : string
  val main : string list -> unit
end

module type SED = sig
  include COMMAND
  val s_add_expr_no_pos : string
  val s_add_expr : string
end

module Sed : SED = struct
  module List = struct
    include List
    let mapi f l =
      List.rev (snd (List.fold_left (fun (n, l) x -> succ n, f n x :: l) (0, []) l))
    let map f = mapi (fun _ -> f)
  end

  let read file =
    let ic = open_in_bin file in
    let rec aux l =
      match try Some (input_line ic) with _ -> None with
        | None -> l
        | Some s -> aux (s :: l) in
    let l = aux [] in
    let () = close_in ic in
    List.rev l

  let write file contents =
    let oc = open_out_bin file in
    begin
      List.iter (fun s -> output_string oc (s ^ "\n")) contents;
      close_out oc;
    end

  let apply f file =
    write file (f (read file))

  let sed l_sed =
    apply
      (fun file ->
        List.fold_left
          (fun file -> function
            | Some pos, s1, s2 ->
              let reg1 = Str.regexp_string s1 in
              let rec aux rev_file n = function
                | [] -> assert false
                | x :: xs ->
                  if n = pos then
                    List.fold_left (fun l x -> x :: l) ((Str.global_replace reg1 s2 x) :: xs) rev_file
                  else
                    aux (x :: rev_file) (succ n) xs in
              aux [] 1 file

            | None, s1, s2 ->
              let reg1 = Str.regexp_string s1 in
              List.map (Str.global_replace reg1 s2) file)
          file
          l_sed)

  let repl_tbl =
    Str.global_replace (Str.regexp_string "\\t") "\t"
    (* NOTE "\x.." should be replaced too *)

  let s_add_expr = "_add_expr_"
  let s_add_expr_no_pos = "_add_expr_no_pos_"
  let s_title = "sed"

  let main l =
    let rec aux l = function
      | cmd :: n :: s1 :: s2 :: xs when cmd = s_add_expr ->
          aux ((Some (int_of_string n), repl_tbl s1, repl_tbl s2) :: l) xs
      | cmd :: s1 :: s2 :: xs when cmd = s_add_expr_no_pos -> aux ((None, repl_tbl s1, repl_tbl s2) :: l) xs
      | [fic] -> List.rev l, fic
      | _ -> assert false in
    let l, fic = aux [] l in
    sed l fic
end

module Chdir : COMMAND = struct
  let s_title = "chdir"
  let main = function
    | dir :: cmd :: [] ->
        begin
          Printf.kprintf Unix.chdir "%s" dir;
          assert (0 = Sys.command cmd);
        end
    | _ -> assert false
end

module Os_type_mv : COMMAND = struct
  let s_title = "os_type_mv"
  let main = function
    | fic_unix_1 :: fic_unix_2 :: fic_win32_1 :: fic_win32_2 :: [] ->
        if Sys.os_type = "Unix" then
          Unix.rename fic_unix_1 fic_unix_2
        else
          Unix.rename fic_win32_1 fic_win32_2
    | _ -> assert false
end

let ocaml s = [ "ocaml" ; "str.cma" ; "unix.cma" ; s ]
let s_opam = "opam.ml"
let s_main = "main"

let main () =
  match Array.to_list Sys.argv with
    | _ :: cmd_main :: l ->
        snd
          (List.find
             (function s_title, _ -> cmd_main = s_title)
             (List.map
                (fun m -> let module M = (val m : COMMAND) in M.s_title, M.main)
                [ (module Sed : COMMAND)
                ; (module Chdir : COMMAND)
                ; (module Os_type_mv : COMMAND) ]))
          l
    | _ -> assert false
let _ = main ()
