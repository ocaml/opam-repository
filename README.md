This repository contains some package files useful to create a valid
OPAM repository, to be hosted somewhere on the internet.

## Preparing the repository

In order to prepare the repository you will need to:

* download and install [opam](http://www.github.com/OCamlPro/opam/)

* run `make` at the root of this repository. This command will use `opam-mk-repo` so make sure it is in the path.

## Using the repository

Once the repository is ready and exported, you can use it as a standard opam repository. Hence you need to:

* download and install [opam](http://www.github.com/OCamlPro/opam/)

* Tell opam to use the repository:

        opam init <local-name> http://path/to/the/repository

* In case you already have opam installed and set-up, you can just add the repository:

        opam remote -add <local-name> http://path/to/the/repository
        
* In case you want to use opam on the same machine where you've installed the repository:

        opam init <local-name> /local/path/to/the/repository

* Now you can install the packages defined in there. For instance:

       opam install core

  Will install Jane Street `core` library.

## Updating the repository

For each package described by `opam/X.opam` and `descr/X`, `opam-mk-repo` will download the archive
from the address described in `url/X` and add the files from `files/X` in it. If you want to modify
some package files, you'll have to:

* [server-side] delete `archives/X.tar.gz`
* [server-side] run `make`
* [client-side] run `opam update` to take the changes into account
* [client-side] run `opam upgrade` if a package already installed have been modified; this will recompile
  the package and all the packages depending on it.