@1

package "lwt" {
  version     = "2.3.2"

  description = "http://ocsigen.org/lwt/manual"

  sources = [ "http://ocsigen.org/download/lwt-2.3.2.tar.gz" ]

  patches = [
      [ "local://files/ocaml-lwt.install"; "lwt.install" ];
      "local://files/ocaml-lwt.config";
      "local://files/ocaml-lwt.ocp";
      "local://files/ocaml-lwt_ocaml.ocp";
      [ "local://files/ocaml-lwt_init.ml"; "init.ml" ];
      [ "local://files/ocaml-lwt_main.ml"; "myocpbuild.ml" ];
  ]

  make = [ [ "ocp-build" ; "-init" ; "-scan" ]
         ; [ "ln" ; "-s" ; "_obuild/m/m.asm" ; "ocamlfind" ]
         ; [ "export" ; "PATH=:$PATH" ; "&&" ; "ocaml" ; "setup.ml" ; "-configure" ]
         ; [ "./ocamlfind" ] ]
}