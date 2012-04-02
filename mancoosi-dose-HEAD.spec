@1

package "mancoosi-dose" {
  version     = "HEAD"

  description = "Dose library (part of Mancoosi tools)"

  sources = [ "git://scm.gforge.inria.fr/mancoosi-tools/dose.git" ]

  patches = [
      "local://files/mancoosi-dose.install";
      "local://files/mancoosi-dose.config";
      "local://files/mancoosi-dose.ocp";
  ]

  make = [
      "ocp-get config -ocp -rstrict mancoosi-dose > depends.ocp";
      "ocp-build dose";
  ]

  depends = "ocaml-re, ocaml-extlib, mancoosi-cudf, ocaml-graph, ocp-get.boot"
}