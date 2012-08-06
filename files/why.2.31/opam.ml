module Sed = struct
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
  let s_main = "Sed.main"
  let s_title = "sed"
  let s_opam = "opam.ml"

  let main () = 
    match Array.to_list Sys.argv with
      | _ :: cmd_main :: l when cmd_main = s_title -> 
        let rec aux l = function
          | cmd :: n :: s1 :: s2 :: xs when cmd = s_add_expr -> 
            aux ((Some (int_of_string n), repl_tbl s1, repl_tbl s2) :: l) xs
          | cmd :: s1 :: s2 :: xs when cmd = s_add_expr_no_pos -> aux ((None, repl_tbl s1, repl_tbl s2) :: l) xs
          | [fic] -> List.rev l, fic
          | _ -> assert false in
        let l, fic = aux [] l in
        sed l fic
      | _ -> assert false
end
let _ = Sed.main ()
