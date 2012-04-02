@1

package "ocp-get.boot" {

  version     = "HEAD" 

  description = "Client for the OCaml PAckage Manager (OPAM)"

  patches     = [
      "https://raw.github.com/OCamlPro/ocp-get/master/boot/ocp-build";
      "https://raw.github.com/OCamlPro/ocp-get/master/boot/ocp-build.boot";
      "https://raw.github.com/OCamlPro/ocp-get/master/boot/ocp-get";
      "https://raw.github.com/OCamlPro/ocp-get/master/boot/ocp-get.boot";
      "local://files/ocp-get.boot.install";
  ]

  make = [ 
      "ocamlc -make-runtime -o unixrun unix.cma str.cma";
      "chmod +x ocp-get ocp-build unixrun"
  ];
}