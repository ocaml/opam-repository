module Type : sig
  type t =
  | Int
  | Int64
  | Float64
  | String of int
end

module Field : sig
  type t = private {
    name  : string;
    type_ : Type.t;
  }

  val create : string -> Type.t -> t
end

module Mem : sig
  type t = {
    ops      : int;
    data     : int;
    num_dims : int;
    flags    : int;
    proxy    : int;
    dim      : int;
  }
end

module Ptr : sig
  type t = {
    mutable ptr : int;
    mem         : Mem.t;
    begin_      : int;
    end_        : int;
    mutable len : int;
    mutable i   : int;
  }

  val unsafe_next : _ -> int -> unit
  val unsafe_prev : _ -> int -> unit
  val unsafe_move : _ -> int -> int -> unit
  val next : _ -> int -> unit
  val prev : _ -> int -> unit
  val move : _ -> int -> int -> unit

  val get_float64  : _ -> int -> _
  val set_float64  : _ -> int -> _ -> unit
  val get_int      : _ -> int -> _
  val set_int      : _ -> int -> _ -> unit
  val get_int64    : _ -> int -> _
  val set_int64    : _ -> int -> _ -> unit
  val get_string   : _ -> int -> int -> string
  val set_string   : _ -> int -> int -> string -> unit

  val seek_int     : _ -> int -> int -> _ -> unit
  val seek_int64   : _ -> int -> int -> _ -> unit
  val seek_float64 : _ -> int -> int -> _ -> unit
  val seek_string  : _ -> int -> int -> int -> string -> unit
end

module type S = sig
  val fields : Field.t list
end

module Make(S : S) : sig
  val fields : Field.t list
  val nfields : int
  val size : int
  val field_names : string array
  val field_offset : int array
  val field_sizes : int array
  
  type t

  val create : unit -> t

  val pos : t -> int
  val has_next : t -> bool
  val has_prev : t -> bool

  module Array : sig
    type e = t
    type t

    val make : int -> t
    val init : int -> (int -> e -> unit) -> t
    val length : t -> int
    val unsafe_get : t -> int -> e
    val get : t -> int -> e
    val iter : t -> f:(e -> unit) -> unit
    val iteri : t -> f:(int -> e -> unit) -> unit

    (** Creates and writes a table. *)
    val make_table : t -> ?title:string -> ?chunk_size:int -> ?compress:bool -> H5caml.t
      -> string -> unit

    (** Adds records to the end of the table. *)
    val append_records : t -> H5caml.t -> string -> unit

    (** Ovewrites records. *)
    val write_records : t -> H5caml.t -> start:int -> string -> unit

    (** Reads a table. *)
    val read_table : H5caml.t -> string -> t

    (** Reads records. *)
    val read_records : H5caml.t -> start:int -> nrecords:int -> string -> t
  end

  val mem : t -> Array.t

  module Vector : sig
    type e = t
    type t

    val create : ?capacity:int -> unit -> t
    val resize : t -> int -> unit
    val append : t -> e
    val unsafe_get : t -> int -> e
    val iter : t -> f:(e -> unit) -> unit
    val of_array : Array.t -> t
    val to_array : t -> Array.t
  end
end
