#include <assert.h>
#include <stdio.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/bigarray.h>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

CAMLprim value ml_stbi_load(value filename, value channels)
{
  CAMLparam1(filename);
  CAMLlocal3(ret, tup, ba);

  int x, y, n;
	unsigned char* image_data =
    stbi_load(String_val(filename), &x, &y, &n, Int_val(channels));

  if (image_data)
  {
    ba = caml_ba_alloc_dims(CAML_BA_UINT8 | CAML_BA_C_LAYOUT, 1, image_data, x * y * n);

    tup = caml_alloc(4, 0);
    Store_field(tup, 0, Val_int(x));
    Store_field(tup, 1, Val_int(y));
    Store_field(tup, 2, Val_int(n));
    Store_field(tup, 3, ba);

    ret = caml_alloc(1, 1);
    Store_field(ret, 0, tup);
  }
  else
  {
    ret = Val_unit;
  }

  CAMLreturn(ret);
}

CAMLprim value ml_stbi_image_free(value ba)
{
  CAMLparam1(ba);
  unsigned char *data = Caml_ba_data_val(ba);

  assert (data);
  stbi_image_free(data);
  Caml_ba_data_val(ba) = NULL;

  CAMLreturn(Val_unit);
}
