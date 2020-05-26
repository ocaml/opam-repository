Contributing to the OCaml opam repository
-----------------------------------------

Contributions under the form of new packages, issue reports and pull
requests to fix and enhance the quality of packages are always
welcome. Thanks for your time and involvement.

Becoming the maintainer of orphaned packages is
[easy](#adopting-and-relinquishing-package-maintainership) and very
welcome.

The following lists a few points that help in making the contribution
process and repository management as smooth and efficient as possible
for everyone involved.

Note that if your have an issue with the opam tool itself this
should not be filed here but on the opam tool
[issue tracker](https://github.com/ocaml/opam/issues).


Reporting package installation issues
-------------------------------------

To report package installation issues:

1. First try to search the issue tracker to see if someone already
   reported the issue. If that is the case mention on this issue that
   you are also affected and, if available, add more diagnostic details.
2. If you create a new issue make sure the issue title mentions the
   package name and the affected version.
3. Try to give as much information as possible about your setup in
   the issue body:
   1. Add the output of `opam config report`
   2. Add the exact opam invocation and the resulting tool output.

Fixing packages
---------------

If you happen to have a fix for a package, please have a look at the
issue tracker to see if it doesn't concern an existing issue. If that
is the case mention it in your pull request.


Adding new packages
-------------------

Information about creating new packages and adding them to repository
is available in
[opam's manual](https://opam.ocaml.org/doc/Packaging.html).


Adopting and relinquishing package maintainership
-------------------------------------------------

Orphaned packages either have no `maintainer:` field or the field is
set to the repository issue tracker:

```
maintainer: "https://github.com/ocaml/opam-repository/issues"
```

If you care about a package and it is orphaned we are keen on having
you as the maintainer of the package. In order to do so simply issue a
pull request on the latest version of the package and add your contact
details in the `maintainer:` field.

If it is no longer possible for you to commit to maintain a package
you can either:

1. Try to find a person to replace yourself in that role. Let her
issue a pull request that updates all the `maintainer:` fields that
contain your details with her own and do acknowledge the transfer on
her pull request.
2. Or, if you cannot find someone to replace you, simply issue a pull
request that updates all the `maintainer:` fields that have your details
with the address of the repository issue tracker (see above).

Other questions
---------------

If your question about contributing is not answered here, please post on the
<https://discuss.ocaml.org> forum in the `ecosystem` category with your query.
Beginners questions are welcome there, particularly since we can use your
question to refine the documentation of the project.
