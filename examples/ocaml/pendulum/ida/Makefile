include ../../../../config

all: pendulum.byte pendulum.opt

test-pendulum: pendulum.opt
	./$< $(PARAMS)

pendulum.byte: showpendulum.ml pendulum.ml
	$(OCAMLC) $(OCAMLFLAGS) -o $@ \
	    $(INCLUDES) -I ../../../../ -dllpath ../../../../ \
	    unix.cma bigarray.cma graphics.cma sundials.cma \
	    showpendulum.ml pendulum.ml

pendulum.opt: showpendulum.cmx pendulum.ml
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -o $@ \
	    $(INCLUDES) -I ../../../../ \
	    unix.cmxa bigarray.cmxa graphics.cmxa sundials.cmxa \
	    showpendulum.ml pendulum.ml

showpendulum.cmo: showpendulum.ml
showpendulum.cmx: showpendulum.ml

clean:
	-@rm -f showpendulum.cmi showpendulum.cmo showpendulum.cmx showpendulum.o
	-@rm -f showpendulum.annot pendulum.annot
	-@rm -f pendulum.cmi pendulum.cmo pendulum.cmx pendulum.o

distclean: clean
	-@rm -f pendulum.byte pendulum.opt

