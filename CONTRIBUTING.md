Contributing to the OCaml opam repository
-----------------------------------------

Contributions under the form of new packages, issue reports and pull
requests to fix and enhance the quality of packages are always
welcome. Thanks for your time and involvement.

Table of content:
* [Add a new package](#add-a-new-package)
* [Fixing packages](#fixing-packages)
* [Governance](#governance)
* [Policies](#policies)
* [How to deal with CI](#how-to-deal-with-ci)

Add a new package
-----------------

There are several ways to add a new package to opam-repository.
You can either use a tool such as `dune-release` or `opam-publish`, or open a PR manually.
Each ones have their strenghts and weaknesses. For example:
* `dune-release` is a tool more focused into helping people do their whole release process from start to finish for them. To that end it:
  * helps with tagging
  * parses (and enforces a format, can be good or bad) for the changelog, to put it in the tag
  * creates the github release with that information
  * builds, run tests, lint
  * uploads the documentation
  * creates and uploads a separate archive (also has an option to include the git submodules)
  * works only if your project is on GitHub
  * doesn’t support force-pushed tags
* `opam-publish` is a more malleable tool focused on publishing. To that end it:
  * works for any type of projects (you can just use a custom archive as an argument)
  * simpler to use than dune-release
  * more focused tool so you should encounter less issues and resistance but it’s more manual
  * only handles the opam linting and publishing
* you can also open a PR manually:
  * this one gives you the most freedom. It is only recommended for experienced users
  * this is however currently the only way to fix packages (as opposed to adding packages). See the appropriate section below

We'll cover each ones in the following subsections:

### using dune-release

*if you encounter any issues, please read [dune-release's README](https://github.com/tarides/dune-release/blob/main/README.md)*

First, make sure your project is using dune and is hosted on GitHub.
Then, make sure you’ve forked opam-repository on GitHub. If not go to https://github.com/ocaml/opam-repository/fork
Then, create a new file in `~/.config/dune/release.yml` with the content as indicated below, change `<username>` by your local username and `<github-user>` by your own github username:
```
remote: git@github.com:<github-username>/opam-repository.git
local: /home/<username>/.cache/dune/opam-repository/
```
Then, you can tag the release using:
```
dune-release tag
```
Once done, you can simply call:
```
dune release
```
If all goes well this should create the Release on GitHub and open the PR to publish the package on opam-repository.

For any subsequent releases only the last two steps are necessary.

### using opam-publish

*if you encounter any issues, please read [opam-publish's README](https://github.com/ocaml-opam/opam-publish/blob/master/README.md)*

Once you have done your release and have an archive available publicly on the internet, simply call:
```
opam-publish <url>
```
This will open the PR to publish the package on opam-repository.

For other options, please refer to `opam-publish --help`

### publish manually

An opam repository is a tree-like structure of directories and files as follow:
```
./
|- packages/
   |- pkgname/
   |  |- pkgname.2.0/
   |     |- opam
   |- another-pkgname/
      |- another-pkgname.1.0.0/
      |  |- opam
      |  |- files/
      |     |- fix1.patch
      |     |- fix2.patch
      |- another-pkgname.1.0.1/
         |- opam
|- ...
```
So to add a package, simply create a directory with your package name (pkgname) and version
```
mkdir -p packages/pkgname/pkgname.version/
```
once done, copy the opam file for said package into the newly created directory.
Edit that copied opam file by removing redundant or forbidden fields such as `name`, `version`, `pin-depends` if present, as well as adding or editing the `url` section as follow:
```
url {
  src: "https://a.publicly-accessible.url/your-archive.tar.gz"
  checksum: [
    "sha256=the-sha256-hash-of-your-archive"
    "sha512=the-sha512-hash-of-your-archive"
  ]
}
```
we recommend using more than one checksum and at least sha256 or stronger. Opam currently supports only md5, sha256 and sha512.

Optionally you might want to integrate files (such as patches) in the repository.
To do so, create a `files` directory in the directory of your package
```
mkdir packages/pkgname/pkgname.version/files/
```
then add the files you want to add to this directory. Note that large files are forbidden and the [extra-source](https://opam.ocaml.org/doc/Manual.html#opamsection-extra-sources) section should be used instead.

Each time you add a file to the `files` directory, you must edit the associated opam file to add the file to the `extra-files` field as follow:
```
extra-files: [
  ["the-filename" "md5=the-checksum-for-that-file"]
  ...
]
```

Once all that is done, you need to create a new git branch, commit your change, push it to your own fork 
```
git switch -c release-yourpkg-version
git add packages/yourpkg/yourpkg.version/
git commit -pm "Release yourpkg.version"
git remote add your-github-handle git@github.com:your-github-handle/opam-repository.git
git push your-github-handle release-yourpkg-version
```
and open a PR on opam-repository on GitHub. Congratulation!

For more technical information about opam files, please read the [opam manual](https://opam.ocaml.org/doc/Manual.html)

Fixing packages
---------------

Packages are fixed as they show up as broken, if the opam-repository maintainers have time.
If, as an external contributor, you are willing to help out, you can send a PR to fix the packages that are broken. This is extremely helpful.

There are several types of fixes:
* **Changes to the metadata** (e.g. `homepage`, `synopsis`, …) are simple, usualy harmless and easy to do and get merged.
* **Changes to the dependencies or availibility** require some scrutiny from the opam-repository maintainers to verify that the new constraints are correct and do not break existing working installations.
* **Changes to the way the package is built** (e.g. changes to the build rules, addition of patches, …) require a lot more scrutiny from the opam-repository maintainers and maybe a new revision.
* **Changes to the source archive(s)** is prohibited but in the case where there is no other choice and the checksum is not the same, the difference with the original must be negligable.

**PSA**: if the PR envisioned is large or involved, please ping the maintainers beforehand.

**IMPORTANT**: If you are maintaining a package that you want to fix, never change the source archive pointed by a package that has already been merged in opam-repository. This would otherwise break anyone who is trying to install it and the archive's checksum would change which renders the installation impossible. Sending a PR in opam-repository that change this checksum is **prohibited** (see [wiki/Policies](https://github.com/ocaml/opam-repository/wiki/Policies)). Instead, if the already released version is broken in some way you can send a PR making it `available: false` and make a new point-release. If this is really too complicated or impossible, you can also send a patch.

#### Revisions

Revision versions are packages whose version is of the form `<version>-<revision>` with the revision number typically starting at 1.
They typically privide a slightly modified version of an original release.

For example `pkg.1.0.0` is not maintained anymore (be it this specific version or the package as a whole), and someone would like to privide a patch to fix something that some people might rely on even if it might be a buggy behivour. In this case the package is duplicated into the original version (left untouched) and the revision with the fix. This way, if the fix broke someone's setup they case still use the original version.

#### Patches

To fix packages, patches might sometimes be useful. This can be given to a package through the [patches field](https://opam.ocaml.org/doc/Manual.html#opamfield-patches), and either added through the [extra-source section](https://opam.ocaml.org/doc/Manual.html#opamsection-extra-sources) or the [extra-files field and the files/ subdirectory](https://opam.ocaml.org/doc/Manual.html#opamfield-extra-files) (`extra-source` is preferred to avoid making opam-repository too big).

As a rule of thumb, unless urgent, the patch should go through upstream first and only if the maintainer is not responding in a reasonable timeframe, we can then think about including the patch in opam-repository, the focus should be for upstream to do a new release.

As an external contributor looking to patch a package, whose maintainer do not agree with it or is unresponsive, another solution could be to fork the project or ask the current maintainer to transfer the maintenance to you.

Governance
----------

The current points of contact and the full list of maintainers is available in [wiki/Governance](https://github.com/ocaml/opam-repository/wiki/Governance).
Informations about the infrastructure is available in [wiki/Infrastructure-info](https://github.com/ocaml/opam-repository/wiki/Infrastructure-info).

Typically maintainers gather weekly to discuss ongoing topics, review PRs together and train maintainers in training.
If you wish to help and become an opam-repository maintainer, you can send a message to the maintainers listed above and you will be invited to the next meeting in which they will explain how things work.

Policies
--------

Maintainers enforce a certain number of policies applied on packages in opam-repository.
You can read about them in [wiki/Policies](https://github.com/ocaml/opam-repository/wiki/Policies).

How to deal with CI
-------------------

When you open a PR, a number of checks are done to verify that builds and runs correctly on a number of different platforms.
You can read about how to deal with our CI (Continuous Integration) in [wiki/How-to-deal-with-CI](https://github.com/ocaml/opam-repository/wiki/How-to-deal-with-CI).
