

let () =
  if not (Sys.file_exists "configure") then
    exit (Sys.command "autoconf")
