open Bigarray
type buffer = (int, int8_unsigned_elt, c_layout) Array1.t

type t = {
  width: int;
  height: int;
  channels: int;
  data: buffer;
}

external ml_stbi_load : string -> int -> t option = "ml_stbi_load"
external ml_stbi_image_free : buffer -> unit = "ml_stbi_image_free"

let load_unmanaged ?(channels=0) filename =
  ml_stbi_load filename channels

let free_unmanaged image =
  ml_stbi_image_free image.data

let load ?channels filename =
  match load_unmanaged ?channels filename with
  | None -> None
  | Some image ->
    let data = Array1.create int8_unsigned c_layout (Array1.dim image.data) in
    Array1.blit image.data data;
    free_unmanaged image;
    Some {image with data}

let width t = t.width
let height t = t.height
let channels t = t.channels
let data t = t.data
