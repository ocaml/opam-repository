open Bigarray
open Hdf5_raw

(** Represents a directory handle inside a HDF5 file. *)
type t

(** Creates the named file and returns the root directory. *)
val create_trunc : string -> t

(** Opens the named file for reading and returns the root directory. *)
val open_rdonly : string -> t

(** Opens the named file for reading and writing and returns the root directory. *)
val open_rdwr : string -> t

(** Opens the named subdirectory.  The subdirectory is created if it does not already
    exists. *)
val open_dir : t -> string -> t

(** Closes the given directory handle. *)
val close : t -> unit

(** Flushes all buffers associated with a file to disk. *)
val flush : t -> unit

(** Returns the name of file to which object belongs. *)
val get_name : t -> string

(** Returns whether the given subdirectory or a data set exists. *)
val exists : t -> string -> bool

(** Returns all subdirectories and data sets. *)
val ls : t -> ?index:Hdf5_raw.H5.Index.t -> ?order:Hdf5_raw.H5.Iter_order.t -> string
  -> string list

(** Copies data. *)
val copy : src:t -> src_name:string -> dst:t -> dst_name:string -> unit

(** Merges the source into the destination. *)
val merge : src:t -> dst:t -> unit

(** Returns the HDF5 handle *)
val hid : t -> Hid.t

(** Writes the given float array to the data set. *)
val write_float_array : t -> string -> ?deflate:int -> float array -> unit

(** Reads the data set into a float array.
    
    @param data If provided, the storage for the data. *)
val read_float_array : t -> ?data:float array -> string -> float array

(** Writes the given float Array1.t to the data set. *)
val write_float_array1 : t -> string -> ?deflate:int -> (float, float64_elt, _) Array1.t
  -> unit

(** Reads the data set into a float Array1.t.
    
    @param data If provided, the storage for the data. *)
val read_float_array1 : t -> ?data:(float, float64_elt, 'a) Array1.t -> string
  -> (float, float64_elt, 'a) Array1.t

(** Writes the given float Array1.t to the data set. *)
val write_float_array2 : t -> string -> ?deflate:int -> (float, float64_elt, _) Array2.t
  -> unit

(** Reads the data set into a float Array2.t.
    
    @param data If provided, the storage for the data. *)
val read_float_array2 : t -> ?data:(float, float64_elt, 'a) Array1.t -> string
  -> (float, float64_elt, 'a) Array2.t

(** Writes the given uint8 Array1.t to the data set. *)
val write_uint8_array1 : t -> string -> ?deflate:int
  -> (char, int8_unsigned_elt, _) Array1.t -> unit

(** Reads the data set into a uint8 Array1.t.
    
    @param data If provided, the storage for the data. *)
val read_uint8_array1 : t -> ?data:(char, int8_unsigned_elt, 'a) Array1.t -> string
  -> (char, int8_unsigned_elt, 'a) Array1.t

(** Writes the given array of float arrays as a matrix. *)
val write_float_array_array : t -> string -> ?transpose:bool -> ?deflate:int
  -> float array array -> unit

(** Reads the given matrix as an array of float arrays. *)
val read_float_array_array : t -> ?transpose:bool -> string -> float array array

(** [write_attribute_string_array t dataset_name attribute_name v] writes the given
    [string array] as the given attribute for the given dataset or directory. *)
val write_attribute_string_array : t -> string -> string -> string array -> unit

(** [read_attribute_string_array t dataset_name attribute_name] reads the given attribute
    of the given dataset or directory as a string array. *)
val read_attribute_string_array : t -> string -> string -> string array
