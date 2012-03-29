@1

package "ocpget" {
  version     = "max_int"
  description = "https://github.com/OCamlPro/ocp-get"
  urls = [ "git://https://github.com/OCamlPro/ocp-get.git" ]
  patches = [ "local://files/ocpget.install"
            ; "local://files/ocpget.ocp"
            ; "local://files/ocp-build" ]
  make = [ "rm ocp-get.ocp lib/bat.ocp"
         ; "for i in ocpgetboot ; do echo 'begin library \"bat\" dirname = \"'$(ocp-get config -I $i | cut -d ' ' -f 2)'\" end' >> ocpget.ocp ; done"
         ; "./ocp-build ocpget" ]

  depends = "cudf, dose, extlib, ocamlarg, ocamlgraph, ocpgetboot"
}