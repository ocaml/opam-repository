@1

package "altergo" {

  version = "0.94"

  description = "http://alt-ergo.lri.fr"

  sources = [ "http://alt-ergo.lri.fr/http/alt-ergo-0.94.tar.gz" ]

  patches = [
      "local://files/app-altergo.install";
      "local://files/app-altergo.ocp"
  ]

  make = [ # let s_let = Printf.sprintf "let %s = \"\"" in let oc = open_out "version.ml" in let () = List.iter (fun s -> output_string oc (s_let s)) [ "version" ; "libdir" ] in close_out oc #
         ; [ "ocp-build" ; "altergo" ] ]

  depends = [ [ ["ocaml-graph"] ] ]
}
