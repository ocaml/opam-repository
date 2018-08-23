Checkseum
=========

Chekseum is a library which implements ADLER-32 and CRC32C Cyclic Redundancy
Check. It provides 2 implementation, the first in C and the second in OCaml. The
library is on top of [`optint`](https://github.com/dinosaure/optint.git) to get
the best representation of the CRC in the OCaml world.

Then, as [`digestif`](https://github.com/mirage/digestif.git), `checkseum` uses
the linking trick. So if you want to use `checkseum` in a library, you can link
with the `checkseum` package which **does not** provide an implementation. Then,
end-user can choose between the C implementation or the OCaml implementation
(both work on Mirage).

Of course, you can link directly to `checkseum.c` or `checkseum.ocaml` if you
want to make an executable directly.
