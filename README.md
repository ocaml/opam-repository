This repository contains some package files useful to create a valid
OPAM repository, to be hosted somewhere on the internet.

In order to prepare the repository you will need:

* to download and install
  [opam](http://www.github.com/OCamlPro/opam/tree/release-0.1) (the
  `release-0.1` branch)

* to run `make` at the root of this repository

* to run `opam init default .` at the root of this repository (you can
  change `default` to be any name you want). If you host this
  repository on the internet, you can run:

        `opam init default http://path/to/the/repository`

Now you can install the packages defined in there. For instance:

   opam install core

Will install Jane Street `core` library.
