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
