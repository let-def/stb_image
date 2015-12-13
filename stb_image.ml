open Bigarray

type 'a result = ('a, [`Msg of string]) Result.result

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

external load_unmanaged    : ?channels:int -> string   -> int8 t result    = "ml_stbi_load"
external loadf_unmanaged   : ?channels:int -> string   -> float32 t result = "ml_stbi_loadf"
external decode_unmanaged  : ?channels:int -> _ buffer -> int8 t result    = "ml_stbi_load_mem"
external decodef_unmanaged : ?channels:int -> _ buffer -> float32 t result = "ml_stbi_loadf_mem"

external ml_stbi_image_free : _ buffer -> unit = "ml_stbi_image_free"
let free_unmanaged image =
  ml_stbi_image_free image.data

let copy buf =
  let buf' = Array1.create (Array1.kind buf) c_layout (Array1.dim buf) in
  Array1.blit buf buf';
  buf'

let manage f ?channels filename =
  match f ?channels filename with
  | Result.Error _ as err -> err
  | Result.Ok image ->
    let managed = {image with data = copy image.data} in
    free_unmanaged image;
    Result.Ok managed

let load    ?channels filename = manage load_unmanaged ?channels filename
let loadf   ?channels filename = manage loadf_unmanaged ?channels filename
let decode  ?channels filename = manage decode_unmanaged ?channels filename
let decodef ?channels filename = manage decodef_unmanaged ?channels filename

let width    t = t.width
let height   t = t.height
let channels t = t.channels
let data     t = t.data
