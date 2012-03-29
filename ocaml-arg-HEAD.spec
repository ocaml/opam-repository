@1

package "ocaml-arg" {
  version     = "HEAD"
  description = "Extended arg module"
  urls        = [ "git://github.com/samoht/ocaml-arg.git" ]
  patches     = [
      "local://files/ocaml-arg.install";
      "local://files/ocaml-arg.ocp"
  ]
  make    = [ "ocp-build arg" ]
  depends = "ocp-get.boot"
}