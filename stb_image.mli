(*
  Stb_image for OCaml by Frédéric Bour <frederic.bour(_)lakaban.net>
  To the extent possible under law, the person who associated CC0 with
  Stb_image for OCaml has waived all copyright and related or neighboring
  rights to Stb_image for OCaml.

  You should have received a copy of the CC0 legalcode along with this
  work. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

  Website: https://github.com/def-lkb/stb_image
  stb_image is a public domain library by Sean Barrett,
  http://nothings.org/
  Version 0.1, September 2015
*)
open Bigarray

type 'a result = ('a, [`Msg of string]) Result.result


(*##############################*)
(** {1 Image representation} *)

(** [buffer] simply is an alias to a bigarray with c_layout.
    The [buffer] type serves two purposes:
    - representing input files,
    - representing the raw pixels of an image.

    Two kind of pixel buffers are manipulated:
    - int8 for images with 8-bit channels
    - float32 for images with floating point channels *)
type 'kind buffer = ('a, 'b, c_layout) Array1.t
  constraint 'kind = ('a, 'b) kind

type float32 = (float, float32_elt) kind
type int8 = (int, int8_unsigned_elt) kind

(** A record describing an image.
    The buffer contains [channels * width * height] items, in this order:
    - channels are interleaved
    - each pixel is made of [channels] items
    - each line is made of [width] pixels
    - image is made of [height] lines *)
type 'kind t = {
  width: int;
  height: int;
  channels: int;
  data: 'kind buffer;
}

(** {2 Image accessors} *)

val width    : _ t -> int
val height   : _ t -> int
val channels : _ t -> int
val data     : 'kind t -> 'kind buffer

(** {1 Image decoding} *)

(** Load an 8-bit per channel image from a filename.
    If [channels] is specified, it has to be between 1 and 4 and the decoded image
    will be processed to have the requested number of channels. *)
val load    : ?channels:int -> string   -> int8 t result

(** Load a floating point channel image from a filename.
    See [load] for [channels] parameter. *)
val loadf   : ?channels:int -> string   -> float32 t result

(** Decode an 8-bit per channel image from a buffer.
    See [load] for [channels] parameter. *)
val decode  : ?channels:int -> _ buffer -> int8 t result

(** Decode a floating point channel image from a buffer.
    See [load] for [channels] parameter. *)
val decodef : ?channels:int -> _ buffer -> float32 t result

(** {2 Low-level interface}

    Functions are similar to the above one, except memory is not managed by OCaml GC.
    It has to be released explicitly with [free_unmanaged] function.

    You get slightly faster load times, more deterministic memory use and more responsibility.
    Use at your own risk! *)

val load_unmanaged    : ?channels:int -> string   -> int8 t result
val loadf_unmanaged   : ?channels:int -> string   -> float32 t result
val decode_unmanaged  : ?channels:int -> _ buffer -> int8 t result
val decodef_unmanaged : ?channels:int -> _ buffer -> float32 t result
val free_unmanaged: _ t -> unit

