open Stdcompat

let format_process_status fmt (ps : Unix.process_status) : unit =
  match ps with
  | WEXITED code -> Format.fprintf fmt "return code %d" code
  | WSIGNALED signal -> Format.fprintf fmt "signal number %d" signal
  | WSTOPPED signal -> Format.fprintf fmt "stopped by signal %d" signal

let with_open_process_in command f =
  Printf.eprintf "%s: %!" command;
  let channel = Unix.open_process_in command in
  let result =
    try f channel
    with exc ->
      ignore (Unix.close_process_in channel);
      raise exc
  in
  match Unix.close_process_in channel with
  | WEXITED 0 ->
      Printf.eprintf "OK\n%!";
      result
  | ps ->
      Printf.eprintf "%s\n%!" (Format.asprintf "%a" format_process_status ps);
      failwith (Format.asprintf "%s: %a" command format_process_status ps)

(* temp_dir is missing in stdcompat.19 *)
let temp_dir prefix suffix =
  let path = Filename.temp_file prefix suffix in
  Sys.remove path;
  Sys.mkdir path 0o700;
  path

let with_temp_dir prefix suffix f =
  let temp_dir = temp_dir prefix suffix in
  Fun.protect
    (fun () -> f temp_dir)
    ~finally:(fun () ->
      let remove_file filename =
        Sys.remove (Filename.concat temp_dir filename)
      in
      Array.iter remove_file (Sys.readdir temp_dir);
      Sys.rmdir temp_dir)

(* input_lines is missing in stdcompat.19 *)
let input_lines ic =
  let rec aux accu =
    match Stdlib.input_line ic with
    | line -> aux (line :: accu)
    | exception End_of_file -> List.rev accu
  in
  aux []

let lines_of_command (command : string) : string list =
  with_open_process_in command input_lines

let line_of_command (command : string) : string =
  match lines_of_command command with
  | [ result ] -> result
  | [] -> failwith (Printf.sprintf "%s: unexpected empty output" command)
  | _ :: _ :: _ ->
      failwith
        (Printf.sprintf "%s: unexpected output with multiple lines" command)

let lookup_command (command : string) : string option =
  match
    line_of_command (Filename.quote_command "command" [ "-v"; command ])
  with
  | result -> Some result
  | exception Failure _ -> None

let expand_glob (pattern : string) : string list =
  (* pattern should not be quoted *)
  match lines_of_command ("ls -1 " ^ pattern) with
  | lines -> lines
  | exception Failure _ -> []

type hasher = { prefix : string; command : string; arguments : string list }

let opam_hash_string hasher hash = Printf.sprintf "%s=%s" hasher hash

let hash_file (filename : string) : string =
  let try_hasher (hasher : hasher) =
    match
      line_of_command
        (Filename.quote_command hasher.command
           (hasher.arguments @ [ filename ]))
    with
    | exception Failure _ -> None
    | result ->
        let first_space_index = String.index result ' ' in
        let hash = String.sub result 0 first_space_index in
        Some (opam_hash_string hasher.prefix hash)
  in
  match
    List.find_map try_hasher
      [
        { prefix = "sha512"; command = "sha512sum"; arguments = [] };
        { prefix = "sha512"; command = "shasum"; arguments = [ "-a"; "512" ] };
        { prefix = "md5"; command = "md5sum"; arguments = [] };
        { prefix = "md5"; command = "md5"; arguments = [ "-q" ] };
      ]
  with
  | None -> opam_hash_string "md5" (Digest.file filename)
  | Some hash -> hash
