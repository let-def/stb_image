Stb\_image is an OCaml binding to stb\_image from Sean Barrett, [Nothings](http://nothings.org/):

  stb\_image.h: public domain C image loading library

The OCaml binding is released under CC-0 license.  It has no dependency beside
working OCaml and C compilers (stb\_image is self-contained).

```shell
$ make
$ make install
```

## CHANGELOG

Version 0.5, Fri Jun 28 19:45:20 CEST 2019
  Bug fix in C-bindings, fixed by @LaurentMazare

Version 0.4, Wed Jan 17 20:52:19 JST 2018
  Image specification can now contain offset and stride (BREAKING CHANGE).
  Add filtering primitives (blur and mipmap)

Version 0.3, Thu Nov  3 18:26:45 CET 2016
  Update to stb\_image.h v2.12

Version 0.2, Sun Dec 13 15:18:39 CET 2015
  Make use of result package

Version 0.1, Fri Sep 18 20:53:03 CET 2015
  Initial release
