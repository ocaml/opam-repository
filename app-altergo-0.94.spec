@1

package "altergo" {

  version = "0.94"

  description = "http://alt-ergo.lri.fr"

  patches = [
      "http://alt-ergo.lri.fr/http/alt-ergo-0.94.tar.gz";
      "local://files/app-altergo.install";
      "local://files/app-altergo.ocp"
  ]

  make = [ "echo 'let version = \"\" let libdir = \"\"' > version.ml"
         ; "ocp-build altergo" ]

  depends = "ocaml-graph"
}
