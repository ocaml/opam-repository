open Stdcompat

let find_system_llvm_config () : string option =
  Utils.lookup_command "llvm-config"

let find_brew_default_llvm_config () : string option =
  match Utils.line_of_command "brew --prefix" with
  | prefix -> Some (Filename.concat prefix "opt/llvm/bin/llvm_config")
  | exception Failure _ -> None

let list_find_llvm_config_version (version : int) : (unit -> string option) list
    =
  let f command_format () =
    Utils.lookup_command (Printf.sprintf command_format version)
  in
  List.map f
    [
      "llvm-config-%d";
      "llvm-config-%d.0";
      "llvm-config%d0";
      "llvm-config%d";
      "llvm-config-%d-64";
      "llvm-config-%d-32";
      "llvm-config-mp-%d";
      "llvm-config-mp-%d.0";
    ]

let list_find_brew_llvm_config_version (version : int) :
    (unit -> string option) list =
  let f package () =
    match
      Utils.line_of_command
        (Filename.quote_command "brew" [ "--cellar"; package ])
    with
    | exception Failure _ -> None
    | prefix -> (
        match
          Utils.expand_glob
            (Printf.sprintf "%s/%d*/bin/llvm-config" prefix version)
        with
        | filename :: _ -> Some filename
        | [] -> None)
  in
  List.map f [ Printf.sprintf "llvm@%d" version; "llvm" ]

let split_command_args cmdline =
  List.filter (fun s -> s <> "") (String.split_on_char ' ' cmdline)

let check_llvm_usability version_major llvm_config =
  let llvm_cflags =
    Utils.line_of_command (Filename.quote_command llvm_config [ "--cflags" ])
  in
  let llvm_ldflags =
    Utils.line_of_command (Filename.quote_command llvm_config [ "--ldflags" ])
  in
  let llvm_libdir =
    Utils.line_of_command (Filename.quote_command llvm_config [ "--libdir" ])
  in
  let llvm_cflags_list = split_command_args llvm_cflags in
  let llvm_ldflags_list = split_command_args llvm_ldflags in
  let predicate cflag =
    cflag <> "-Wstring-conversion"
    (*  Filter -Wstring-conversion for OpenSUSE *)
    && cflag <> "-Werror=unguarded-availability-new"
    && cflag <> "-Wcovered-switch-default"
    && cflag <> "-Wdelete-non-virtual-dtor"
  in
  let llvm_cflags_list = List.filter predicate llvm_cflags_list in
  Utils.with_temp_dir "conf-libclang" "" (fun temp_dir ->
      let source_code = Filename.concat temp_dir "test_libclang.c" in
      Out_channel.with_open_text source_code (fun oc ->
          Out_channel.output_string oc
            {|
#include <clang-c/Index.h>
#include <stdlib.h>

int
main(int argc, char *argv[])
{
  CXIndex idx = clang_createIndex(1, 1);
  clang_disposeIndex(idx);
  return EXIT_SUCCESS;
}
|});
      let object_file = Filename.concat temp_dir "test_libclang.o" in
      let executable_file = Filename.concat temp_dir "test_libclang" in
      Utils.with_open_process_in
        (Filename.quote_command "cc"
           ([ "-o"; object_file; "-c" ] @ llvm_cflags_list @ [ source_code ]))
        ignore;
      (try
         Utils.with_open_process_in
           (Filename.quote_command "cc"
              ([ "-o"; executable_file ] @ llvm_ldflags_list
              @ [ object_file; "-lclang"; "-Wl,-rpath," ^ llvm_libdir ]))
           ignore
       with Failure _ ->
         (* On Ubuntu 23.04, libclang.so is a dead symbolic link,
            but we can link to libclang-16.so.1 *)
         Utils.with_open_process_in
           (Filename.quote_command "cc"
              ([ "-o"; executable_file ] @ llvm_ldflags_list
              @ [
                  object_file;
                  Printf.sprintf "-l:libclang-%d.so.1" version_major;
                  "-Wl,-rpath," ^ llvm_libdir;
                ]))
           ignore);
      Utils.with_open_process_in executable_file ignore)

type variable = { name : string; value : string }

type config = {
  llvm_config : string;
  llvm_version : string;
  variables : variable list;
}

let write_config_file config =
  let checksum = Utils.hash_file config.llvm_config in
  Out_channel.with_open_text "conf-libclang.config" (fun oc ->
      Out_channel.output_string oc
        (Printf.sprintf
           {|opam-version: "2.0"
file-depends: [ "%s" "%s" ]
variables {
|}
           config.llvm_config checksum);
      let variables =
        [
          { name = "config"; value = config.llvm_config };
          { name = "version"; value = config.llvm_version };
        ]
        @ config.variables
      in
      variables
      |> List.iter (fun { name; value } ->
             Out_channel.output_string oc
               (Printf.sprintf {|  %s: "%s"
|} name value));
      Out_channel.output_string oc {|}
|})

let check_version maximum_version find_llvm_config =
  match find_llvm_config () with
  | Some llvm_config -> (
      match
        Utils.line_of_command
          (Filename.quote_command llvm_config [ "--version" ])
      with
      | exception Failure _ -> None
      | llvm_version ->
          let version_major = Scanf.sscanf llvm_version "%d." Fun.id in
          if version_major <= maximum_version then
            match check_llvm_usability version_major llvm_config with
            | () ->
                let variables =
                  match version_major with
                  | 14 ->
                      [
                        {
                          name = "clangml460_configure_options";
                          value = "--with-llvm-version=14.0.0";
                        };
                      ]
                  | _ -> []
                in
                Some { llvm_config; llvm_version; variables }
            | exception Failure _ -> None
          else None)
  | _ -> None

let find_llvm_config maximum_version =
  match
    List.find_map
      (check_version maximum_version)
      [ find_system_llvm_config; find_brew_default_llvm_config ]
  with
  | Some config -> Some config
  | None ->
      let rec loop version =
        if version < 3 then None
        else
          match
            List.find_map
              (check_version maximum_version)
              (list_find_llvm_config_version version
              @ list_find_brew_llvm_config_version version)
          with
          | Some config -> Some config
          | None -> loop (version - 1)
      in
      loop maximum_version

let find_and_write_llvm_config maximum_version =
  match find_llvm_config maximum_version with
  | Some config -> write_config_file config
  | None ->
      failwith
        (Printf.sprintf "No usable version of LLVM <=%d.0.x found"
           maximum_version)

let () =
  match Sys.argv with
  | [| _; maximum_version |] ->
      find_and_write_llvm_config (int_of_string maximum_version)
  | _ -> failwith "Usage: configure.ml version"
