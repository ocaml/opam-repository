@1

package "ocaml-arg" {
  version     = "HEAD"
  description = "Extended arg module"
  patches     = [
      "git://github.com/samoht/ocaml-arg.git";
      "local://files/ocaml-arg.install";
      "local://files/ocaml-arg.config";
      "local://files/ocaml-arg.ocp"
  ]
  make    = [ "ocp-build arg" ]
  depends = "ocp-get.boot"
}