@1

package "mancoosi-cudf" {
  version     = "0.6.2"

  description = "CUDF library (part of the Mancoosi tools)"

  sources = [ "http://www.ocamlpro.com/pub/cudf.tar.bz2" ]

  patches = [
      "local://files/mancoosi-cudf.install";
      "local://files/mancoosi-cudf.config";
      "local://files/mancoosi-cudf.ocp";
  ]

  make = [
      "ocp-get config -ocp ocaml-extlib > depends.ocp";
      "ocp-build cudf" ]

  depends = "ocaml-extlib, ocp-get.boot"
}