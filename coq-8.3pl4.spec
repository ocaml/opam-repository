@1

package "coq" {

  version = "8.3pl4"

  description = "http://coq.inria.fr"

  patches = [ "http://coq.inria.fr/distrib/V8.3pl4/files/coq-8.3pl4.tar.gz"
            ; "local://files/coq.install" ]

  make = [ "./configure -camlp5dir $(ocp-get config -I camlp5 | cut -d ' ' -f 2) -local -coqide no -with-doc no -debug"
         ; "make world" ]

  depends = "camlp5"
}
