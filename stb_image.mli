open Bigarray

type buffer = (int, int8_unsigned_elt, c_layout) Array1.t

type t = {
  width: int;
  height: int;
  channels: int;
  data: buffer;
}

val load_unmanaged: ?channels:int -> string -> t option
val free_unmanaged: t -> unit

val load: ?channels:int -> string -> t option
val width: t -> int
val height: t -> int
val channels: t -> int
val data: t -> buffer
