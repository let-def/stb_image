#include <assert.h>
#include <stdio.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/bigarray.h>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

static int Channels_val(value channel)
{
  CAMLparam1(channel);
  int ret = 0;
  if (channel != Val_unit)
    ret = Long_val(Field(channel, 0));
  CAMLreturn(ret);
}

static value return_image(void *data, int ty, int x, int y, int n)
{
  CAMLparam0();
  CAMLlocal3(ret, tup, ba);

  ba = caml_ba_alloc_dims(ty | CAML_BA_C_LAYOUT, 1, data, x * y * n);

  tup = caml_alloc(4, 0);
  Store_field(tup, 0, Val_long(x));
  Store_field(tup, 1, Val_long(y));
  Store_field(tup, 2, Val_long(n));
  Store_field(tup, 3, Val_long(0));
  Store_field(tup, 4, Val_long(x * n));
  Store_field(tup, 5, ba);

  /* Result.Ok tup */
  ret = caml_alloc(1, 0);
  Store_field(ret, 0, tup);

  CAMLreturn(ret);
}

static value return_failure(void)
{
  CAMLparam0();
  CAMLlocal3(ret, str, err);

  str = caml_copy_string(stbi_failure_reason());

  /* `Msg "str" */
  err = caml_alloc(2, 0);
  Store_field(err, 0, Val_long(3854881));
  Store_field(err, 1, str);

  /* Result.Error (`Msg "str") */
  ret = caml_alloc(1, 1);
  Store_field(ret, 0, err);

  CAMLreturn(ret);
}

CAMLprim value ml_stbi_load(value channels, value filename)
{
  CAMLparam2(channels, filename);
  CAMLlocal1(ret);

  int x, y, n;
	unsigned char* image_data =
    stbi_load(String_val(filename), &x, &y, &n, Channels_val(channels));

  if (image_data)
    ret = return_image(image_data, CAML_BA_UINT8, x, y, n);
  else
    ret = return_failure();

  CAMLreturn(ret);
}

CAMLprim value ml_stbi_loadf(value channels, value filename)
{
  CAMLparam2(channels, filename);
  CAMLlocal1(ret);

  int x, y, n;
	float* image_data =
    stbi_loadf(String_val(filename), &x, &y, &n, Channels_val(channels));

  if (image_data)
    ret = return_image(image_data, CAML_BA_FLOAT32, x, y, n);
  else
    ret = return_failure();

  CAMLreturn(ret);
}

CAMLprim value ml_stbi_load_mem(value channels, value mem)
{
  CAMLparam2(channels, mem);
  CAMLlocal1(ret);

  int x, y, n;
	unsigned char* image_data =
    stbi_load_from_memory(Caml_ba_data_val(mem),
        caml_ba_byte_size(Caml_ba_array_val(mem)),
        &x, &y, &n, Channels_val(channels));

  if (image_data)
    ret = return_image(image_data, CAML_BA_UINT8, x, y, n);
  else
    ret = return_failure();

  CAMLreturn(ret);
}

CAMLprim value ml_stbi_loadf_mem(value channels, value mem)
{
  CAMLparam2(channels, mem);
  CAMLlocal1(ret);

  int x, y, n;
	float* image_data =
    stbi_loadf_from_memory(Caml_ba_data_val(mem),
        caml_ba_byte_size(Caml_ba_array_val(mem)),
        &x, &y, &n, Channels_val(channels));

  if (image_data)
    ret = return_image(image_data, CAML_BA_FLOAT32, x, y, n);
  else
    ret = return_failure();

  CAMLreturn(ret);
}

CAMLprim value ml_stbi_image_free(value ba)
{
  CAMLparam1(ba);
  void *data = Caml_ba_data_val(ba);

  assert (data);
  stbi_image_free(data);
  Caml_ba_data_val(ba) = NULL;

  CAMLreturn(Val_unit);
}

#define POUT(x,n) pout[x] = (pin[x] + pin[n + x] + pin[w * n + n] + pin[w * n + x]) / 4
#define POUTf(x,n) pout[x] = (pin[x] + pin[n + x] + pin[w * n + n] + pin[w * n + x]) / 4.0f

#define LOOP(w,h,n) \
  for (unsigned int y = 0, w2 = (w) / 2, h2 = (h) / 2; \
       y < h2; ++y, pin0 += sin, pin = pin0, pout0 += sout, pout = pout0) \
    for (unsigned int x = 0; x < w2; ++x, pin += 2 * n, pout += n)

CAMLprim value ml_stbi_mipmap(value img_in, value img_out)
{
  CAMLparam2(img_in, img_out);
  unsigned char *pin, *pout,
    *pin0 = Caml_ba_data_val(Field(img_in, 5)),
    *pout0 = Caml_ba_data_val(Field(img_out, 5));
  assert (pin0 && pout0);

  pin0 += Long_val(Field(img_in, 3));
  pout0 += Long_val(Field(img_out, 3));

  unsigned int
    sin = Long_val(Field(img_in, 4)),
    sout = Long_val(Field(img_out, 4)),
    w = Long_val(Field(img_in, 0)),
    h = Long_val(Field(img_in, 1));

  switch (Long_val(Field(img_in, 2))) {
    case 1:
      LOOP(w, h, 1) { POUT(0, 1); }
      break;
    case 2:
      LOOP(w, h, 2) { POUT(0, 2); POUT(1, 2); }
      break;
    case 3:
      LOOP(w, h, 3) { POUT(0, 3); POUT(1, 3); POUT(2, 3); }
      break;
    case 4:
      LOOP(w, h, 4) { POUT(0, 4); POUT(1, 4); POUT(2, 4); POUT(3, 4); }
      break;
  }

  CAMLreturn(Val_unit);
}

CAMLprim value ml_stbi_mipmapf(value img_in, value img_out)
{
  CAMLparam2(img_in, img_out);
  float *pin, *pout,
    *pin0 = Caml_ba_data_val(Field(img_in, 5)),
    *pout0 = Caml_ba_data_val(Field(img_out, 5));
  assert (pin0 && pout0);

  pin0 += Long_val(Field(img_in, 3));
  pout0 += Long_val(Field(img_out, 3));

  unsigned int
    sin = Long_val(Field(img_in, 4)),
    sout = Long_val(Field(img_out, 4)),
    w = Long_val(Field(img_in, 0)),
    h = Long_val(Field(img_in, 1));

  switch (Long_val(Field(img_in, 2))) {
    case 1:
      LOOP(w, h, 1) { POUTf(0, 1); }
      break;
    case 2:
      LOOP(w, h, 2) { POUTf(0, 2); POUTf(1, 2); }
      break;
    case 3:
      LOOP(w, h, 3) { POUTf(0, 3); POUTf(1, 3); POUTf(2, 3); }
      break;
    case 4:
      LOOP(w, h, 4) { POUTf(0, 4); POUTf(1, 4); POUTf(2, 4); POUTf(3, 4); }
      break;
  }

  CAMLreturn(Val_unit);
}
