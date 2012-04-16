@1

package "lwt" {
  version     = "2.3.2"

  description = "http://ocsigen.org/lwt/manual"

  sources = [ "http://ocsigen.org/download/lwt-2.3.2.tar.gz" ]

  patches = [
      "local://files/ocaml-lwt.install";
      "local://files/ocaml-lwt.config";
      "local://files/ocaml-lwt.ocp";
      "local://files/ocaml-lwt_ocaml.ocp";
      "local://files/ocaml-lwt_init.ml";
      "local://files/ocaml-lwt_main.ml";
  ]

  make = [ # List.iter (fun (s1, s2) -> Unix.rename s1 s2) [ "ocaml-lwt_init.ml", "init.ml" ; "ocaml-lwt_main.ml", "myocpbuild.ml" ; "ocaml-lwt.install", "lwt.install" ] #
         ; [ "ocp-build" ; "-init" ; "-scan" ]
         ; [ "ln" ; "-s" ; "_obuild/m/m.asm" ; "ocamlfind" ]
         ; [ "export" ; "PATH=:$PATH" ; "&&" ; "ocaml" ; "setup.ml" ; "-configure" ]
         ; [ "./ocamlfind" ] ]

  depends = []
}