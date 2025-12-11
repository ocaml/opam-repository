# opam Repository Policies

This document lists the explicit policies governing the maintenance and curation
of the opam repository.

*NOTE*: This policy is not static and will be updated as needed.

<a name="policy-0"></a>
## 0. Packages must meet the criteria for inclusion

Packages in this repository should meet the [criteria for inclusion](./archiving.md#inclusion-criteria)
enumerated in the [archiving policy](./archiving.md).

## 1. Removal of packages should be avoided

#### Exceptions:

* Packages that no longer satisfy [policy 0](#policy-0).
* In case of a mistake, reverting a PR is allowed if the revert happened reasonably soon after the merge (e.g. < 1 day), to make sure a minimal number of users have pulled the repository in a state where the PR was in.
* Packages that are irredeemably broken can be marked with `available: false`
* Packages whose author want inaccessible for security reasons can be marked with `available: false`
* Packages whose author want gone from opam-repository can make their case with a PR marking them with `available: false`. If the package(s) in question are not used by any other packages the PR should be good to merge, otherwise, a case by case basis, at the discretion of the opam-repository maintainers, is applied.
* Case by case basis

#### Reasoning:

* Users should be able to rely on any versions that have ever been available without breakage.
* Users that use opam < 2.1.6 or opam < 2.2.0~beta2 on macOS can sometimes lack GNU patch. The default macOS patch command does not support removal of files and would make `opam update` fail.

## 2. Packages should not be modified in a way that makes it uninstallable with an existing and working setup

#### Exceptions:

* Known security issues with a combination of dependencies
* Non-deterministic or hard to properly fix failures
* Case by case basis

#### Reasoning:

* Users should be able to rely on any versions that have ever been available without breakage.
* Users should be able to keep the packages that they have installed if they are working fine.

## 3. Packages should provide some sort of utility for users

#### Exceptions:

* Case by case basis

#### Reasoning:

* Packages providing very little utility (e.g. one module with just one function defined as a one liner) do not seem justified to go in opam-repository and take one of the available names and space in the git repository that every user has to download
* opam-repository is a curated package repository, we hope to provide useful packages for the large majority of OCaml users

## 4. Namesquatting practices and misleading names are forbidden

#### Exceptions:

* Case by case basis

#### Reasoning:

* Being misled when installing a package is pretty frustrating for users.
* If a package has a compatible interface as another and users mixup their name often, it can become a security risk.
* Developers spending time on a software, to find a package with the same name exists in opam-repository already and was added with malicious intents by another person, would be extremely frustrating for the developer and confusing for users if the project had been publicly announced prior.

## 5. Strict dependency constraints should be avoided (=, > or preventive upper bounds)

#### Exceptions:

* Strict equality constraints with packages that live in the same source repository (`{= version}`) are accepted (and even encouraged) if the maintainer in planning to publish all the packages in that repository at once everytime there is some change. While this leads to a number of packages that are the same as their previous versions, this simplifies releases for maintainers that are in those cases, and makes the link simpler between the tag in their source repository and the version number in opam-repository.
* Early `<` constraints are allowed if it is known for sure that the package will not be compatible with said upcoming version or to prevent likely runtime failures with a next major version for example.
* Case by case basis

#### Reasoning:

* Strict constraints (in particular `=` and `<=`/`<`) make the user experience worse by disallowing the combination of several packages requiring different strict dependencies in the same opam switch.
* Strict constraints also make the work of opam-repository maintainers harder by the sheer number of PR that would simply change the constraints of a package.
* Strict constraints also make testing of the opam ecosystem worse by not testing the new releases of packages against packages that might be compatible with them (reverse dependencies, aka. revdeps).
* It is prefered to use `>=` over `>` when writing dependency constraints because it makes constraints easier to read in most cases and would include potential package revisions or point-releases. For example `> "1.0.0"` would also include a potential `1.0.0-1` revision in the future, and `> "0.9"` would also include a potential `0.9.1` release that might not exists at the moment and that might not include the fix you need.
* It is prefered to use `<` over `<=` when writing dependency constraints because it would ignore any revision packages. For example `<= "1.0.0"` would not take into account a potential `1.0.0-1`, and `<= "0.9"` would not take into account a potential `0.9.1` release.

## 6. Version numbers should not have a v prefix (not v1.2.0 but 1.2.0)

#### Exceptions:

* Packages that are linked with already existing suite of packages that have adopted this version scheme for historical reasons.
* Packages whose maintainers want/need to change the version scheme to a version number that would be below the latest available version. For example `sexplib.113.33.03` was the latest version of that package before Jane Street decided to reset the version scheme for readability reason to `0.9.0`, however 0.9.0 < 113.33.03 so the `v` prefix is here to make sure the order of version is kept, as 0.9.0 < 113.33.03 < v0.9.0. See [the opam manual section on version ordering](https://opam.ocaml.org/doc/Manual.html#version-ordering) for more details.
* Case by case basis

#### Reasoning:

* It is much easier for users to write version constraints if they don't have to second guess for each dependencies if the version number contains a `v` prefix or not.

## 7. New package names should avoid the ocaml prefix/suffix

#### Exceptions:

* Packages relating to the OCaml compiler
* Packages for whom `ocaml` is historically a part of the name and not a simple suffix (e.g. ocamlfind, ocamlgraph, ocamldap, …)
* Packages whose name without the prefix/suffix would evoke something else that might also be an opam package or lack context (e.g. ocaml-lsp-server, ocaml-manual, …)
* Case by case basis

#### Reasoning:

* opam-repository is an OCaml focused repository, so while many projects' name start with `ocaml-` or end with `-ocaml`, if all of their package name would also include `ocaml` it would quickly become fairly annoying and redundant for users.

## 8. Developement packages (e.g. pointing to a git branch) are to be avoided

#### Exceptions:

* OCaml compilers and related packages related to a fast moving branch are exempt
* Case by case basis

#### Reasoning:

* Maintaining the metadata for many developement packages would mean too much work for the opam-repository maintainers.
* The resulting package would be too brittle and would break easily
* On the user's side, such package would lack checksum and thus have to be redownloaded and kept uptodate, everytime they do `opam update`

## 9. Packages should only depend on packages they depend on at build time or runtime

#### Exceptions:

* Case by case basis

#### Reasoning:

* opam-repository currently strives to make installation as lightweight as possible for users of those packages. If a package were to install dependencies that is only used by (for example) developers of said package, it would be detrimental to their user experience, by having to compile and install packages they're not going to use. Example of such packages are: `ocamlformat`, `merlin`, …. Which are in 99% of cases only required when developing a package. For people who want to install developement dependencies however, opam 2.2 introduced the `with-dev-setup` variable.

## 10. Binary packages should be avoided

#### Exceptions:

* Case by case basis

#### Reasoning:

* opam is a source based package manager, it is not currently designed to handle portable binary packages properly.
* As it currently stands adding a binary package would require the facilities to ensure compatibilities with subarchitectures (e.g. x86_64 v1, …) which we do not have.
* opam-repository currently strives to provide the same experience regardless of your platform. Binary package would go against that as each platform would have to be packaged separately, or downloaded all together and sort which one to use on site. Either of these solutions would make the user's experience worse and the maintainers life worse as well.

## 11. Changes to a package's source archive are prohibited (including patches and other ways to modify the source)

#### Exceptions:

* No exceptions

#### Reasoning:

* opam-repository packages are expected to be able to install at any time. Packages have a checksum to verify there hasn't been any malicious or unexpected changes to the archive after downloading it. If the source archive were to be changed, everyone who tries to install it would only receive failures, and even if it was fixed in a subsequent PR, it would still break users who have not used `opam update`. Adding, modifying, or removing patches of an opam file is prohibited. If you need to patch a released version, please submit a new opam files (where the version is the old with -1 (or -2, etc.) appended: patching foo.0.1.3 will become foo.0.1.3-1). Additionally, changing the build instructions to modify sources (e.g. a `sed` or `awk` script) is as well prohibited. The reasoning for this is security: we aim to record in an immutable way the exact sources that were used for a build with a given package version.

## 12. Extra-files are prohibited (patches in the `files/` subdirectory)

The [extra-files field](https://opam.ocaml.org/doc/Manual.html#opamfield-extra-files) is not allowed in this repository. Please use [extra-source](https://opam.ocaml.org/doc/Manual.html#opamsection-extra-sources) if you need to include external files.

#### Exceptions:

* No exceptions

#### Reasoning:

* opam-repository is trying to use a minimal amount of files and size, thus any files not required are prohibited.
* For cryptographic signing of the repository, not allowing extra-files reduces the complexity thereof.

See the [announcement](https://discuss.ocaml.org/t/ann-opam-repository-policy-change-checksums-no-md5-and-no-extra-files/14720) and [discussion](https://github.com/ocaml/opam-repository/issues/25876) for further details.

## 13. Weak hash algorithms (md5) are prohibited

To prepare opam-repository for signing, adding only weak hash algorithms as checksums is prohibited.

#### Exceptions:

* No exceptions

#### Reasoning:

* Weak hash algorithms would induce that cryptographic signatures would be weak, or would need another set of checksums. This is costly and convolutes the repository.

See the [announcement](https://discuss.ocaml.org/t/ann-opam-repository-policy-change-checksums-no-md5-and-no-extra-files/14720) and [discussion](https://github.com/ocaml/opam-repository/issues/25876) for further details.
