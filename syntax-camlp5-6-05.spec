@1

package "camlp5" {

  version = "6.05"

  description = "http://pauillac.inria.fr/~ddr/camlp5"

  urls = [ "http://pauillac.inria.fr/~ddr/camlp5/distrib/src/camlp5-6.05.tgz" ]

  patches = [ "local://files/syntax-camlp5.install" ]

  make = [ "./configure -bindir $(pwd)/_obuild/bin -libdir $(pwd)/_obuild -mandir $(pwd)/_obuild"
         ; "make world.opt"
         ; "make install" ]
}
