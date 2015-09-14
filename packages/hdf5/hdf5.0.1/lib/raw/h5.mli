module Time : sig
  type t = int64
end

module Addr : sig
  type t = int
end

module Iter_order : sig
  type t =
  | INC
  | DEC
  | NATIVE
  | N
end

module Iter : sig
  type t =
  | CONT
  | STOP
end

module Index : sig
  type t =
  | NAME
  | CRT_ORDER
  | N
end

module Ih_info : sig
  type t = {
    index_size : int;
    heap_size  : int }
end
