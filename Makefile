OCAMLC=ocamlfind c
OCAMLOPT=ocamlfind opt
OCAMLMKLIB=ocamlfind mklib

EXT_DLL=$(shell $(OCAMLC) -config | grep ext_dll | cut -f 2 -d ' ')
EXT_LIB=$(shell $(OCAMLC) -config | grep ext_lib | cut -f 2 -d ' ')
EXT_OBJ=$(shell $(OCAMLC) -config | grep ext_obj | cut -f 2 -d ' ')

CFLAGS=-O3 -std=gnu99 -ffast-math

all: stb_image.cma stb_image.cmxa

ml_stb_image$(EXT_OBJ): ml_stb_image.c
	$(OCAMLC) -c -ccopt "$(CFLAGS)" $<

dll_stb_image_stubs$(EXT_DLL) lib_stb_image_stubs$(EXT_LIB): ml_stb_image$(EXT_OBJ)
	$(OCAMLMKLIB) -o _stb_image_stubs $<

stb_image.cmi: stb_image.mli
	$(OCAMLC) -package result -c $<

stb_image.cmo: stb_image.ml stb_image.cmi
	$(OCAMLC) -package result -c $<

stb_image.cma: stb_image.cmo dll_stb_image_stubs$(EXT_DLL)
	$(OCAMLC) -package result -a -custom -o $@ $< \
	       -dllib dll_stb_image_stubs$(EXT_DLL) \
	       -cclib -l_stb_image_stubs

stb_image.cmx: stb_image.ml stb_image.cmi
	$(OCAMLOPT) -package result -c $<

stb_image.cmxa stb_image$(EXT_LIB): stb_image.cmx dll_stb_image_stubs$(EXT_DLL)
	$(OCAMLOPT) -package result -a -o $@ $< \
	       -cclib -l_stb_image_stubs

.PHONY: clean install uninstall reinstall

clean:
	rm -f *$(EXT_LIB) *$(EXT_OBJ) *$(EXT_DLL) *.cm[ixoa] *.cmxa

DIST_FILES=                      \
	stb_image$(EXT_LIB)            \
	stb_image.cmi                  \
	stb_image.cmo                  \
	stb_image.cma                  \
	stb_image.cmx                  \
	stb_image.cmxa                 \
	stb_image.ml                   \
	stb_image.mli                  \
	lib_stb_image_stubs$(EXT_LIB)  \
	dll_stb_image_stubs$(EXT_DLL)

install: $(DIST_FILES) META
	ocamlfind install stb_image $^

uninstall:
	ocamlfind remove stb_image

reinstall:
	-$(MAKE) uninstall
	$(MAKE) install
