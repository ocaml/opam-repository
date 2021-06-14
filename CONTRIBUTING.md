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

If you are using `dune` and hosting your git repository on `github` you can use the following tutorial that provides a step-by-step procedure to
make a `hello` package available in opam.ocaml.org.
If you are not using `dune` or hosting your project on `github` you can still use `opam-publish` as described by the manual page linked above.

The top-level sources contain the following files with the opam file having the same
name of the project.

```
$ ls hello/

src/
dune
dune-project
hello.opam
```

A quick summary of the steps to be followed are listed below:

```
$ dune build
$ dune-release lint
$ dune-release tag
$ dune-release distrib
$ dune-release publish
$ dune-release opam pkg
$ dune-release opam submit
```

We will now go through each of the above commands in detail:

* `dune build`

The OCaml source package needs to be built with `dune`, `dune-project`
and `.opam` files along with the sources. The build should be
successful before proceeding further. For example:

```
$ dune build
Done: 56/61 (jobs: 1)
```

* `dune-release lint`

The `lint` command checks for the presence of meta files in the
project folder, and also runs `opam lint`. A sample output is given
below for your reference:

```
$ dune-release lint
[ OK ] File README is present.
[ OK ] File LICENSE is present.
[ OK ] File CHANGES is present.
[ OK ] File opam is present.
[ OK ] lint opam file hello.opam.
[ OK ] opam field description is present
[ OK ] opam fields homepage and dev-repo can be parsed by dune-release
[ OK ] Skipping doc field linting, no doc field found
[ OK ] lint /home/guest/hello success
```

You need to fix any errors reported by linting, and commit the changes
locally.

* `dune-release tag`

A ChangeLog `CHANGES` file is required, and the format used is
available in the
[dune-release](https://github.com/ocamllabs/dune-release)
documentation. A minimal example is as follows:

```
$ cat CHANGES

## v0.0.1 (2021-02-23)
### Added
- Meta files for dune release
```

After updating the CHANGES file, you need to tag the release. You will
be prompted to confirm the version, as can be seen in the following
output:

```
$ dune-release tag
[-] Extracting tag from first entry in CHANGES
[-] Using tag "v0.0.1"
[?] Create git tag v0.0.1 for HEAD? [Y/n]
Y
[+] Tagged HEAD with version v0.0.1
```

* `dune-release distrib`

The sources are then archived to create a distribution as illustrated
below:

```
 $ dune-release distrib
[-] Building source archive
[+] Wrote archive _build/hello-v0.0.1.tbz

[-] Linting distrib in _build/hello-v0.0.1
[ OK ] File README is present.
[ OK ] File LICENSE is present.
[ OK ] File CHANGES is present.
[ OK ] File opam is present.
[ OK ] lint opam file hello.opam.
[ OK ] opam field description is present
[ OK ] opam fields homepage and dev-repo can be parsed by dune-release
[ OK ] Skipping doc field linting, no doc field found
[ OK ] lint _build/hello-v0.0.1 success

[-] Building package in _build/hello-v0.0.1
Done: 56/60 (jobs: 1)[ OK ] package builds

[-] Running package tests in _build/hello-v0.0.1
Done: 0/0 (jobs: 0)[ OK ] package tests

[+] Distribution for hello 0.0.1
[+] Commit c9935ac42271ce23cc422c299c5c3aaf92646499
[+] Archive _build/hello-v0.0.1.tbz
```

* `dune-release publish`

You can now publish the distribution to your GitHub repository as
follows:

```
$ dune-release publish
[-] Skipping documentation publication for package hello: no doc field in hello.opam
[-] Publishing distribution
[-] Publishing to github
[?] Push tag v0.0.1 to git@github.com:guest/hello? [Y/n]
Y
[-] Pushing tag v0.0.1 to git@github.com:guest/hello
[?] Create release v0.0.1 on git@github.com:guest/hello? [Y/n]
Y
[-] Creating release v0.0.1 on git@github.com:guest/hello via github's API
[+] Succesfully created release with id 38465706
[?] Upload _build/hello-v0.0.1.tbz as release asset? [Y/n]
Y
[-] Uploading _build/hello-v0.0.1.tbz as a release asset for v0.0.1 via github's API
```

* `dune-release opam pkg`

The .opam file can then be generated using the following command:

```
$ dune-release opam pkg
[-] Creating opam package description for hello
[+] Wrote opam package description _build/hello.0.0.1/opam
```

* `dune-release opam submit`

The `~/.config/dune/release.yml` file should then be updated with your
opam repository settings as indicated below (in particular, change `<username>` by your local username and `<github-user>` by your own github username):

```
$ cat ~/.config/dune/release.yml

user: <username>
remote: git@github.com:<github-username>/opam-repository.git
local: /home/<username>/.cache/dune/opam-repository/
```
```

You can now submit your package to be included to opam.ocaml.org using
the following command, which will create a new pull request to
ocaml/opam-repository:

```
$ dune-release opam submit
[-] Submitting
[-] Preparing pull request to ocaml/opam-repository
[-] Fetching https://github.com/ocaml/opam-repository.git#master
[-] Checking out a local release-hello-0.0.1 branch
[-] Pushing release-hello-0.0.1 to git@github.com:guest/opam-repository
[?] Open PR to ocaml/opam-repository? [Y/n]
Y
[-] Opening pull request to merge branch release-hello-0.0.1 of git@github.com:guest/opam-repository into ocaml/opam-repository
```

Congratulations on submitting your first OCaml package!

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
