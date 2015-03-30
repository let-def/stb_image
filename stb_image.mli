open Bigarray

type 'a result = [ `Ok of 'a | `Error of string ]

type 'kind buffer = ('a, 'b, c_layout) Array1.t
  constraint 'kind = ('a, 'b) kind

type 'kind t = {
  width: int;
  height: int;
  channels: int;
  data: 'kind buffer;
}

type float32 = (float, float32_elt) kind
type int8 = (int, int8_unsigned_elt) kind

val load    : ?channels:int -> string   -> int8 t result
val loadf   : ?channels:int -> string   -> float32 t result
val decode  : ?channels:int -> _ buffer -> int8 t result
val decodef : ?channels:int -> _ buffer -> float32 t result

val width    : _ t -> int
val height   : _ t -> int
val channels : _ t -> int
val data     : 'kind t -> 'kind buffer

val load_unmanaged    : ?channels:int -> string   -> int8 t result
val loadf_unmanaged   : ?channels:int -> string   -> float32 t result
val decode_unmanaged  : ?channels:int -> _ buffer -> int8 t result
val decodef_unmanaged : ?channels:int -> _ buffer -> float32 t result
val free_unmanaged: _ t -> unit

