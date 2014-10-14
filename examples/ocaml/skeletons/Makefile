include ../../../config

EXAMPLES = cvode_skel.byte  \
	   ida_skel.byte    \
	   kinsol_skel.byte

all: $(EXAMPLES)
opt: $(EXAMPLES:.byte=.opt)

cvode_skel.byte: cvode_skel.ml
cvode_skel.opt: cvode_skel.ml

ida_skel.byte: ida_skel.ml
ida_skel.opt: ida_skel.ml

kinsol_skel.byte: kinsol_skel.ml
kinsol_skel.opt: kinsol_skel.ml

# #

clean:
	-@rm -f $(EXAMPLES:.byte=.cmo) $(EXAMPLES:.byte=.cmx)
	-@rm -f $(EXAMPLES:.byte=.o) $(EXAMPLES:.byte=.cmi)
	-@rm -f $(EXAMPLES:.byte=.annot)

distclean: clean
	-@rm -f $(EXAMPLES) $(EXAMPLES:.byte=.opt)

# #

.SUFFIXES : .ml .byte .opt

.ml.byte:
	$(OCAMLC) $(OCAMLFLAGS) -o $@ \
	    $(INCLUDES) -I ../../../ -dllpath ../../../ \
	    bigarray.cma sundials.cma $<

.ml.opt:
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -o $@ \
	    $(INCLUDES) -I ../../../ \
	    bigarray.cmxa sundials.cmxa $<
