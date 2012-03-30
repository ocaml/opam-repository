@1

package "ocp-get" {

  version     = "HEAD"

  description = "Client for the OCaml PAckage Manager (OPAM)"

  urls        = [
      "https://github.com/OCamlPro/ocp-get.git"
  ]

  make = [
      "ocp-get config -ocp -rstrict ocp-get > depends.ocp";
      "ocp-build ocp-get"
  ]

  depends =
    "mancoosi-cudf, mancoosi-dose, ocaml-extlib, ocaml-arg, ocaml-graph"
}