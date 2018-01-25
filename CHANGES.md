## Ppx_deriving becomes an optional dependency of ppx_type_conv

There are two ways of using the `ppx_sexp_conv` ppx rewriter:

- the legacy way, with:
  ```
  $ ocamlfind ocamlc -package ppx_sexp_conv ...
  ```

- the new way, with a driver. Since the v0.9.0 version of
  `ppx_sexp_conv` one can use either the `ocaml-migrate-parsetree`
  driver or `ppx_driver`. Before v0.9.0 one could only use
  `ppx_driver`

Using the legacy way requires using `ppx_deriving`. `ppx_deriving`
used to be a hard dependency of `ppx_sexp_conv` through
`ppx_type_conv`. Since v0.9.0 it is an optional one. As a result
pacakges building using the legacy way must declare an explicit
dependency on `ppx_deriving`.

Many packages didn't at the time `ppx_sexp_conv` v0.9.0 was
released. To fix builds failure, a `ppx_deriving` dependency was added
to all packages depending on `ppx_sexp_conv` but not `ppx_deriving`.

## Split build and install steps (2016-05-18)

The opam tool has been separating the "build" and "install" steps of packages
since version 1.2.2, but historically packages could only define a "build:"
field in their metadata, that did both steps. There are many usages and tools
that can benefit from the split (like tracking of installed files without losing
build parallelism), and it is cleaner overall.

To upgrade older packages that didn't make the move yet, an heuristic has been
applied to automatically do the split. It's in the
[admin-scripts/split-install.ml](https://github.com/ocaml/opam/blob/ce8605e0572335beb7f9ae04713c9cc8048cf707/admin-scripts/split_install.ml)
script and simply reads commands from the end, detecting calls to `install`,
`cp` to appropriate destinations, and commands mentioning `install`.

The main invariant to respect is that the `build` stage should never write
outside of its build directory and the temp dir, while the `install` stage
should be as fast as possible. So in case of doubt, it is better to put
everything in `install:` instead (but we don't do that automatically, since many
correct packages only have `build:` and a `.install` file, which we can't detect
from the metadata alone).

In turn, opam guarantees that `install` and `remove` commands are never run
concurrently.

Please remember to correctly split the two stages from now on, as advised by
`opam lint`; tools to check the invariants are being put in place.

## Camlp4 syntax extensions split from Jane Street packages (2016-01-11)

Jane Street packages no longer support camlp4 after the 113.09.00
series.

For Jane Street packages that contain both a library and a camlp4
syntax extension, the latter is extracted to its own package.

The following table summarize the changes:

Package     | Old findlib name of syntax | New camlp4-only package | version
------------|----------------------------|-------------------------|----------
sexplib     | sexplib.syntax             | pa\_sexp\_conv          | 113.00.00
bin\_prot   | bin\_prot.syntax           | pa\_bin\_prot           | 113.00.00
typerep     | typerep.syntax             | pa\_typerep\_conv       | 113.00.00
fieldslib   | fieldslib.syntax           | pa\_fields\_conv        | 113.00.00
variantslib | variantslib.syntax         | pa\_variants\_conv      | 109.15.03

### Upgrading

For the long term it is recommended to switch to the corresponding ppx
alternative (replace the pa\_ prefix by ppx\_ to get the ppx package
name).

Until then packages that are using one of the camlp4 syntax extension
must upgrade their build system to refer to the new package
name. Simply replace the name in the second column by the one in the
third column.

Running the following shell command on the sources should do:

    sed -ri 's/\<sexplib\.syntax\>/pa_sexp_conv/g;
             s/\<bin_prot\.syntax\>/pa_bin_prot/g;
             s/\<typerep\.syntax\>/pa_typerep_conv/g;
             s/\<fieldslib\.syntax\>/pa_fields_conv/g;
             s/\<variantslib\.syntax\>/pa_variants_conv/g' \
      `ag -l .`

The new dependency must also be added to the opam file.

### Automatic upgrade of the opam-repository

To avoid the opam-repository being in a inconsistent state once the
camlp4-free Jane Street packages are released, the following automatic
change is applied to the
[opam repository](https://github.com/ocaml/opam-repository):

```
for js_pkg in "sexplib" "bin_prot" "type_conv" "variantslib" "fieldslib":
  for pkg in all_packages():
    if pkg depends on js_pkg and "type_conv":
      pkg.add_constraint(js_pkg < next-version-of(js_pkg))
```

This is an over-approximation as some package might not use the syntax
extension at all.

Following this automatic change maintainers should:

- just remove the constraint if the package doesn't use the syntax extension
- do a new release that depend on the new camlp4-only package
