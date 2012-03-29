@1

package "ocamlgraph" {
  version     = "1.8.1"
  description = "http://ocamlgraph.lri.fr/doc"
  urls = [ "http://ocamlgraph.lri.fr/download/ocamlgraph-1.8.1.tar.gz" ]
  patches = [ "local://files/ocamlgraph.install"
            ; "local://files/ocamlgraph.ocp" ]
  make = [ "ocp-build -init -scan" ]
}