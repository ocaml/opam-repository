@1

package "cudf" {
  version     = "0.6.2"
  description = "http://www.mancoosi.org/reports/tr3.pdf"
  urls = [ "http://www.ocamlpro.com/pub/cudf.tar.bz2" ]
  patches = [ "local://files/cudf.install"
            ; "local://files/cudf.ocp"
            ; "local://files/ocp-build" ]
  make = [ "./ocp-build cudf" ]
  depends = "extlib"
}