@1

package "ocaml-re" {
  version     = "HEAD"

  description =
      "Pure OCaml regular expressions, with Support for Perl and POSIX-style strings"

  urls        = [
      "https://github.com/samoht/ocaml-re.git"
  ]

  patches     = [
      "local://files/ocaml-re.install";
      "local://files/ocaml-re.config";
      "local://files/ocaml-re.ocp"
  ]

  make    = [ "ocp-build re" ]

  depends = "ocp-get.boot"
}