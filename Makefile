OCAMLC=ocamlfind c
OCAMLOPT=ocamlfind opt

# determine shared library extension for target system
ifeq ($(strip $(OS)),Windows_NT)
	shared_ext=dll
else
	shared_ext=so
endif

all: stb_image.cma stb_image.cmxa

ml_stb_image.o: ml_stb_image.c
	$(OCAMLC) -c -ccopt "-O3 -std=gnu99 -ffast-math" $<

dll_stb_image_stubs.$(shared_ext) lib_stb_image_stubs.a: ml_stb_image.o
	ocamlmklib \
	    -o _stb_image_stubs $< \
	    -ccopt -O3 -ccopt -std=gnu99 -ccopt -ffast-math

stb_image.cmi: stb_image.mli
	$(OCAMLC) -package result -c $<

stb_image.cmo: stb_image.ml stb_image.cmi
	$(OCAMLC) -package result -c $<

stb_image.cma: stb_image.cmo dll_stb_image_stubs.$(shared_ext)
	$(OCAMLC) -package result -a -custom -o $@ $< \
	       -dllib dll_stb_image_stubs.$(shared_ext) \
	       -cclib -l_stb_image_stubs

stb_image.cmx: stb_image.ml stb_image.cmi
	$(OCAMLOPT) -package result -c $<

stb_image.cmxa stb_image.a: stb_image.cmx dll_stb_image_stubs.$(shared_ext)
	$(OCAMLOPT) -package result -a -o $@ $< \
		-cclib -l_stb_image_stubs \
		-ccopt -O3 -ccopt -std=gnu99 -ccopt -ffast-math

.PHONY: clean install uninstall reinstall

clean:
	rm -f *.[oa] *.$(shared_ext) *.cm[ixoa] *.cmxa

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
	dll_stb_image_stubs.$(shared_ext)

install: $(DIST_FILES) META
	ocamlfind install stb_image $^

uninstall:
	ocamlfind remove stb_image

reinstall:
	-$(MAKE) uninstall
	$(MAKE) install
