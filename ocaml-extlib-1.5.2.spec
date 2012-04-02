@1

package "ocaml-extlib" {
  version     = "1.5.2"

  description = "http://ocaml-extlib.googlecode.com/svn/doc/apiref/index.html"

  sources = [
      "http://ocaml-extlib.googlecode.com/files/extlib-1.5.2.tar.gz"
  ]

  patches = [
      "local://files/ocaml-extlib.install";
      "local://files/ocaml-extlib.config";
      "local://files/ocaml-extlib.ocp"
  ]

  make    = [ "ocp-build extlib" ]

  depends = "ocp-get.boot"
}