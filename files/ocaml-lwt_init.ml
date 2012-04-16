  let read_lines ic =
    let lines = ref [] in
    try while true do
        let line = input_line ic in
        (*if not (Filename.concat line "" = line) then*)
        lines := line :: !lines;
      done;
        !lines
    with _ ->
      !lines

  let read_command_output_ cmd =
    let ic = Unix.open_process_in cmd in
    let lines = read_lines ic in
    if Unix.close_process_in ic <> Unix.WEXITED 0 then
      None
    else
      Some lines

  let command fmt = 
    Printf.kprintf
      (fun s -> 
        let _ = Printf.eprintf "%s\n%!" s in
        if Sys.command s = 0 then
          ()
        else
          failwith s) fmt

  let Some (ocaml_lib :: _) = read_command_output_ "ocamlc -where"

module Find = 
struct
  open Printf

  let (//) = Filename.concat

  let find_list = 
    let twenty = 19 in
    List.map
      (fun s ->
        String.concat ""
          [ s
          ; (let l = String.length s in
             if l > twenty then "" else String.make (twenty - l) ' ')
          ; " (version: [distributed with Ocaml])" ])
      
      [ "bigarray"
      ; "camlp4"
      ; "camlp4.exceptiontracer"
      ; "camlp4.extend"
      ; "camlp4.foldgenerator"
      ; "camlp4.gramlib"
      ; "camlp4.lib"
      ; "camlp4.listcomprehension"
      ; "camlp4.locationstripper"
      ; "camlp4.macro"
      ; "camlp4.mapgenerator"
      ; "camlp4.metagenerator"
      ; "camlp4.profiler"
      ; "camlp4.quotations"
      ; "camlp4.quotations.o"
      ; "camlp4.quotations.r"
      ; "camlp4.tracer"
      ; "dbm"
      ; "dynlink"
      ; "graphics"
      ; "labltk"
      ; "num"
      ; "ocamlbuild"
      ; "stdlib"
      ; "str"
      ; "threads"
      ; "unix" ]

  let exit_with f = 
    begin
      f ();
      exit 0;
    end

  let _ = 
    match Array.to_list Sys.argv with
      | [ _ ; "query" ; "-format" ; format ; lib_name ] -> 
          exit_with
            (fun _ -> 
              printf "%s\n%!" 
                (match format, lib_name with
                  | "%v", "findlib" -> "1.2.8"
                  | _ when (try String.sub lib_name 0 6 = "camlp4" with _ -> false) -> ocaml_lib // "camlp4"
                  | _ -> ocaml_lib))
            
      | [ _ ; "list" ] ->
          exit_with 
            (fun _ -> List.iter (printf "%s\n%!") find_list)
      | _ -> ()
end
