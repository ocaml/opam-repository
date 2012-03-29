@1

package "ocpgetboot" {
  version     = "max_int"
  description = "https://github.com/OCamlPro/ocp-get"
  urls = [ "git://https://github.com/OCamlPro/ocp-get.git" ]
  patches = [ "local://files/ocpgetboot.install"
            ; "local://files/ocpgetboot.ocp"
            ; "local://files/ocp-build" ]
  make = [ "rm ocp-get.ocp"
         ; "./ocp-build ocpgetboot" ]
  depends = "extlib, ocamlre"
}