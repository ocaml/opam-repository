@1

package "altergo" {
  version = "0.94"
  description = "http://alt-ergo.lri.fr"
  urls = [ "http://alt-ergo.lri.fr/http/alt-ergo-0.94.tar.gz" ]
  patches = [ "local://files/altergo.install"
            ; "local://files/altergo.ocp"
            ; "local://files/ocp-build" ]
  make = [ "echo 'let version = \"\" let libdir = \"\"' > version.ml"
         ; "./ocp-build altergo" ]
  depends = "ocamlgraph"
}
