This repository contains OCaml package and compiler metadata and is used by the default installation of [opam](https://opam.ocaml.org/).

The state of the package ecosystem can be explored using opam-health-check<sup>[[1]]</sup>: http://check.ci.ocaml.org/

## Periodic Archival and Troubleshooting

In 2025 we introduced a policy and set of processes to move unmaintained or obsolete package versions to the [opam-repository-archive](https://github.com/ocaml/opam-repository-archive). 

The main downside is that unmaintained packages's versions, that are not needed to build any of the maintained
ones, will periodically disappear from the repository. You can have a
[look at the policy here](https://github.com/ocaml/opam-repository/blob/master/governance/policies/archiving.md).
If this is the case, you may encouter an opam error of the form:
```
[ERROR] Package conflict!
  * Missing dependency:
    - local-package-foo → local-package-bar → dune = 3.17.2 → dune.3.17.2: no longer available
```

When this happens, there are three ways to move forward:
- tell us about your dependencies (open an issue to this repository, please include the package and version, together with a hyperlink where it is used, so that we can "unarchive" it back to this repository);
- use in your setup the opam-repository-archive as another repository: `opam repository add archive https://github.com/ocaml/opam-repository-archive`
- use in your setup the opam-repository before the archiving took place: `opam repo set-url default git+https://github.com/ocaml/opam-repository.git#2025-06-before-archiving-phase3` (where the tag depends on the archival that affected you)

## How to Contribute

Contributions are welcome !

The [CONTRIBUTING.md](CONTRIBUTING.md) document has general guidelines
on how to contribute and add new packages.

## License

All the metadata contained in this repository are licensed under the
[CC0 1.0 Universal](http://creativecommons.org/publicdomain/zero/1.0/)
license.

Moreover, as the collection of the metadata in this repository is
technically a "Database" -- which is subject to a "sui generis" right
in Europe -- we would like to stress that even the *collection* of
the metadata contained in opam-repository is licensed under CC0 and
thus the simple act of cloning opam-repository is perfectly legal.

[1]: https://github.com/ocurrent/opam-health-check
