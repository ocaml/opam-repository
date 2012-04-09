@1

package "ocaml-graph" {

  version     = "1.8.1"

  description = "A graph library for OCaml"

  sources     = [
      "http://ocamlgraph.lri.fr/download/ocamlgraph-1.8.1.tar.gz"
  ]

  patches = [
      "local://files/ocaml-graph.install";
      "local://files/ocaml-graph.config";
      "local://files/ocaml-graph.ocp"
  ]

  make    = [ [ "ocp-build" ; "graph" ] ]

  depends = [ [ ["ocp-get.boot"] ] ]
}