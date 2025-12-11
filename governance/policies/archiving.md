# opam Repository Archiving Policy

## Summary

To remain in the primary opam repository, a package version must:

  - Have available sources
  - Be installable (but not necessarily pass tests)
    - on at least one supported platform
    - with at least one recent compiler (currently, meaning 4.08+)
  - Be maintained, according to the metadata of the latest version:
    - `x-maintenance-intent: ["(latest)"]` means that only the latest version is maintained
    - No `x-maintenance-intent` field means (for now) that all versions are maintained
    - Other values are possible (see below for a full list)

Package versions which don't meet these criteria and are not dependencies of
anything meeting these criteria will be periodically archived, removing them
from the primary opam repo.

The full policy, including the precise criteria, the archiving process, and how
package versions may be marked maintained, is detailed below.


## Terminology

- The primary opam repository, (referred to here as the "primary repo") is located at [ocaml/opam-repository](https://github.com/ocaml/opam-repository). The primary repo is curated to ensure that compatible packages are co-installable on as many supported platforms as possible, and it is the default package repository.
- "Primary repo criteria" refers to the criteria used to decide whether a version of a package is suitable for continued inclusion in the primary repo.
- The archive opam repository, (referred to here as the "archive repo") is located at [ocaml/opam-repository-archive](https://github.com/ocaml/opam-repository-archive) and records packages that were once in the primary repo, but no longer meet the primary repo criteria.
- "Supported platforms" are those listed under [Tier 1 and Tier 2 by the OCaml compiler](https://github.com/ocaml/ocaml?tab=readme-ov-file#overview)
- A package's "maximum compiler version" is the upper bound of the OCaml compiler versions supported by a package. Support is derived either based on explicit version bounds set on the `ocaml` dependency in a package's dependency cone, or implicitly based on failed installs detected through our CI and health check processes.
- The "compiler cutoff threshold" is an OCaml compiler versions stipulated by the opam repository maintainers. It sets a lower bound on the compiler versions supported by the primary repo. 
- A package is said to "meet the compiler cutoff threshold" iff its maximum compiler version is greater then or equal to the compiler cutoff threshold.
- The "maintenance intent" of a package refers to the explicitly declared intent of a maintainer to support versions of a package, recorded in the packages `opam` file metadata.

## Policy

### Compiler cutoff threshold

The current (2025-02-01) compiler cutoff threshold is `4.08`.

This threshold is subject to change by the opam repo maintainers.
The threshold is based on the oldest ocaml compiler version available
in the maintained[^1] distributions. It determines the minimum
compiler version used in tests for the opam-repository CI[^2].

[^2]: https://github.com/ocurrent/opam-repo-ci/blob/master/doc/platforms.md#ocaml-versions

<a name="inclusion-criteria"></a>
### Criteria for inclusion to the primary repo (the default `opam-repository`)

A version of a package may be published on the primary repo, and will continue to remain listed there, so long as the following criteria hold:

1. The package meets the compiler cutoff threshold.
2. The sources of the package version are available.
3. The package version falls within a package's maintenance intent, or is a dependency of a package satisfying the primary repo criteria.
4. The package version is installable on at least one of the supported platforms. (Note that it is not required that CI tests are passing, since working installation may require manual system configuration.)

Note that this property is transitive along a package's dependency tree: if a package satisfies the primary repo criteria, then its dependencies do as well.

### Periodic pruning process

At regular intervals, no less than every six months, the opam repo maintainers will reevaluate all packages to determine if they satisfy the [primary repo criteria](#criteria-for-inclusion-to-the-primary-repo-the-default-opam-repository). Packages that do not will be subject to archiving, according to the following process:

- If the package version falls outside the package's maintenance intent, it will be archived.
- The package version's maintainers will be notified of the intent to archive.
  - Maintainers will have two weeks to fix the version so that it satisfies the criteria or approve of the archiving.
  - If two weeks pass without hearing from the maintainers, the package will be marked as unmaintained and a call for a new maintainer will be submitted to the community via [discuss.ocaml.org under the opam-repository topic](https://discuss.ocaml.org/tag/opam-repository).
  - If a new maintainer steps forward, they will have 1 week to fix the package version.
  - Otherwise, the package will be archived.


### Archiving a package

When it has been decided that a set of package versions (aka "versions") should be archived, archiving will proceed according to the following process:

- A PR will be made to add the archived versions to the archive repo.
    - The opam file of each version will be extended as follows:
        - Any dependencies without upper bounds will have upper bounds added, recording the latest available version of the dependency in the primary repo at the time of archiving.
        -  The field `x-reason-for-archiving` will be added.
        -  The field `x-opam-repository-commit-hash-at-time-of-archiving` will be added.
- A PR will be made to remove the versions from the primary repo:
  - The removal PR should link to the corresponding archiving PR.
  - The commit message should have the title `Archive packages` and its body should contain the hash of the commit that adds the packages to the archive.
- An announcement will be made on discuss.ocaml.org
- After waiting 1 week for feedback, the PRs will be merged.

### Specification of the `x-` fields used in the archiving process

- `x-reason-for-archiving`:
    - Allowed values: a list containing one or more of the following strings
      `ocaml-version`, `source-unavailable`, `maintenance-intent`, or
      `uninstallable`.
    - Meaning: Records the unmet [primary repo criteria](#inclusion-criteria)
      motivating the archiving, as follows:
        1. `ocaml-version`: The package no longer met the compiler cutoff threshold.
        2. `source-unavailable`: The sources of the package version became unavailable.
        3. `maintenance-intent`: The package version falls outside of a
           package's maintenance intent, and it is not a dependency of a package
           satisfying any of the primary repo criteria.
        4. `uninstallable`: The package version is not installable on any
           of the supported platforms.
    - Example: `["ocaml-version", "source-unavailable"]`
- `x-opam-repository-commit-hash-at-time-of-archiving`:
    - Allowed values: a string
    - Meaning: Records the commit hash of the primary repo at the time a package version is archived.
    - Example: `"ca32ab3b976aa7abc00c7605548f78a30980d35b"`
- `x-maintenance-intent`:
    - Allowed values: a list of strings matching version numbers, possibly using the special keywords `(latest)`, `(any)` and `(none)`
    - Meaning:
        - Expresses the declared intent of the maintainers to maintain only certain versions ranges of a package.
        - The value of the `x-maintenance-intent` on the latest published package will precedence.
    - Default value: ["(latest)"] since 2026-01-01, please note that this default is expected to change in the future
    - Examples:
        - `["(latest)"]` the maintainer will only maintain the latest version[^caveat]
        [^caveat]: note that this will retain the latest versions of this package so that every supported OCaml version will have an installation candidate.
        - `["(latest)" "(latest-1)"]` the maintainer will only maintain the latest `X.Y.Z` version and `(X-1).Y.Z`
        - `["(latest)" "(latest).(latest-1)"]` the maintainer will only maintain the latest `X.Y.Z` version and `X.(Y-1).Z`
        - `["(any).(latest)"]` the maintainer will maintain every major version X for each X.Y.Z
        - `["(latest).(any).(latest)"]` the maintainer will maintain every Y for each X.Y.Z (where X is the latest)
        - `["(any)"]` the maintainer will maintain every single version
        - `["(none)"]` the maintainer will not maintain any version
        - `["1.3"]` the maintainer will maintain the latest  version of "1.3.Z"
        - `["2.(latest)"]` the maintainer will maintain the latest minor version specifically of version "2" of the package
    - `dune-project` uses [`maintenance_intent`](https://dune.readthedocs.io/en/latest/reference/dune-project/maintenance_intent.html). Example:
        - `(package ... (maintenance_intent "(latest)") ...)`
- `x-maintained`:
    - Allowed values: `true` and `false`
    - Meaning:
        - Expresses that this opam package version is maintained (if `true`) or not (if `false`).
        - Overrides the `x-maintenance-intent` field
        - Useful for packages that do not specify the `x-maintenance-field` yet, but would like to mark certain pre-releases or old releases as unmaintained, and thus ok for archival
        - Also useful if there's need to maintain a specific version (i.e. an OCaml application that is used and maintained which uses a specific package version)
    - Examples:
        - `false` if this package and version meets the `x-maintenance-intent`, but this version is not maintained and can be archived
        - `true # used by @bactrian, added on 2025-01-24` where @bactrian wants to keep this package in the opam-repository

## References

- [Package Archiving: Plan](https://github.com/ocaml/opam-repository/wiki/Package-Archiving:-Plan)
- [Originating issue and discussion](https://github.com/ocaml/opam-repository/issues/23789)

[^1]: The versions of ocaml shipped by linux distributions are accessible on [repology](https://repology.org/project/ocaml/versions). Both homebrew and macports are usually very fast to move to the latest available. Which LTS are still maintained isn't explicit, but it can be found at endoflife dot software (e.g. <https://endoflife.software/operating-systems/linux/ubuntu>).
