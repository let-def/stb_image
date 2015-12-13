OCAMLC=ocamlfind c
OCAMLOPT=ocamlfind opt

all: stb_image.cma stb_image.cmxa

ml_stb_image.o: ml_stb_image.c
	$(OCAMLC) -c -ccopt "-O3 -std=gnu99 -ffast-math" $<

dll_stb_image_stubs.so lib_stb_image_stubs.a: ml_stb_image.o
	ocamlmklib \
	    -o _stb_image_stubs $< \
	    -ccopt -O3 -ccopt -std=gnu99 -ccopt -ffast-math

stb_image.cmi: stb_image.mli
	$(OCAMLC) -package result -c $<

stb_image.cmo: stb_image.ml stb_image.cmi
	$(OCAMLC) -package result -c $<

stb_image.cma: stb_image.cmo dll_stb_image_stubs.so
	$(OCAMLC) -package result -a -custom -o $@ $< \
	       -dllib dll_stb_image_stubs.so \
	       -cclib -l_stb_image_stubs

stb_image.cmx: stb_image.ml stb_image.cmi
	$(OCAMLOPT) -package result -c $<

stb_image.cmxa stb_image.a: stb_image.cmx dll_stb_image_stubs.so
	$(OCAMLOPT) -package result -a -o $@ $< \
	      -cclib -l_stb_image_stubs \
	  		-ccopt -O3 -ccopt -std=gnu99 -ccopt -ffast-math

.PHONY: clean install uninstall reinstall

clean:
	rm -f *.[oa] *.so *.cm[ixoa] *.cmxa

DIST_FILES=              \
	stb_image.a            \
	stb_image.cmi          \
	stb_image.cmo          \
	stb_image.cma          \
	stb_image.cmx          \
	stb_image.cmxa         \
	stb_image.ml           \
	stb_image.mli          \
	lib_stb_image_stubs.a  \
	dll_stb_image_stubs.so

install: $(DIST_FILES) META
	ocamlfind install stb_image $^

uninstall:
	ocamlfind remove stb_image

reinstall:
	-$(MAKE) uninstall
	$(MAKE) install
