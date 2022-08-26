ROOT:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
INSTALL?=$(ROOT)lib

OCAMLFIND?=ocamlfind
OCAMLDEP?=ocamldep

OCAMLFINDFLAGS+=-package ctypes,ctypes.foreign
OCAMLFLAGS+=-strict-sequence -strict-formats \
	-short-paths -keep-locs \
	-g \
	-thread

ifeq ($(SILENT),0)
SILENCER:=
else
SILENCER:=@
endif
ECHO?=echo

all:
.PHONY: all


doc:
	$(SILENCER)$(OCAMLFIND) ocamldoc $(OCAMLFINDFLAGS) \
		src/lib/wasmer.mli -html -d html_out -colorize-code


LIB_INTERFACE:=lib/Wasmer.cmi
TESTS:=test/instance/instance test/hello/hello
EXAMPLES:=examples/hello examples/instance examples/rust

all: wasmer

wasmer: lib/Wasmer.cmxs lib/Wasmer.cmxa lib/Wasmer.cma lib/Wasmer.cmi
.PHONY: wasmer

obj/lib/Wasmer.ml: src/lib/wasmer.ml
	@$(ECHO) "Copying Wasmer ml to the obj directory"
	$(SILENCER)cp src/lib/wasmer.ml obj/lib/Wasmer.ml
obj/lib/Wasmer.mli: src/lib/wasmer.mli
	@$(ECHO) "Copying Wasmer mli to the obj directory"
	$(SILENCER)cp src/lib/wasmer.mli obj/lib/Wasmer.mli

obj/lib/Wasmer.cmi: obj/lib/Wasmer.mli
	@$(ECHO) "Compiling the Wasmer cmi"
	$(SILENCER)$(OCAMLFIND) ocamlc $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-opaque \
		-I obj/lib \
		-no-alias-deps \
		-o obj/lib/Wasmer.cmi \
		obj/lib/Wasmer.mli

obj/lib/Wasmer.cmo: obj/lib/Wasmer.ml obj/lib/Wasmer.cmi
	@$(ECHO) "Compiling the Wasmer cmo"
	$(SILENCER)$(OCAMLFIND) ocamlc $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I obj/lib \
		-no-alias-deps \
		-o obj/lib/Wasmer.cmo \
		-c obj/lib/Wasmer.ml

obj/lib/Wasmer.cmx: obj/lib/Wasmer.ml obj/lib/Wasmer.cmi
	@$(ECHO) "Compiling the Wasmer cmx"
	$(SILENCER)$(OCAMLFIND) ocamlopt $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I obj/lib \
		-no-alias-deps \
		-o obj/lib/Wasmer.cmx \
		-c obj/lib/Wasmer.ml

lib/Wasmer.cmi: obj/lib/Wasmer.cmi
	@$(ECHO) "Copying the Wasmer cmi to lib"
	$(SILENCER)cp obj/lib/Wasmer.cmi lib/Wasmer.cmi

lib/Wasmer.cma: obj/lib/Wasmer.cmo
	@$(ECHO) "Compiling Wasmer cma"
	$(SILENCER)$(OCAMLFIND) ocamlc $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-a \
		-o lib/Wasmer.cma \
		-ccopt -L$(LIBRARY_PATH) -ccopt -Wl,-rpath,$(LIBRARY_PATH) -cclib -lwasmer \
		obj/lib/Wasmer.cmo

lib/Wasmer.cmxa: obj/lib/Wasmer.cmx
	@$(ECHO) "Compiling Wasmer cmxa"
	$(SILENCER)$(OCAMLFIND) ocamlopt $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-a \
		-o lib/Wasmer.cmxa \
		-ccopt -L$(LIBRARY_PATH) -ccopt -Wl,-rpath,$(LIBRARY_PATH) -cclib -lwasmer \
		obj/lib/Wasmer.cmx

lib/Wasmer.cmxs: lib/Wasmer.cmxa
	@$(ECHO) "Compiling Wasmer cmxs"
	$(SILENCER)$(OCAMLFIND) ocamlopt $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-shared -linkall \
		-I obj/lib \
		-o lib/Wasmer.cmxs \
		lib/Wasmer.cmxa


obj/test/hello/hello.cmo: $(LIB_INTERFACE) src/test/hello/hello.ml
	@$(ECHO) "Compiling test 'hello' cmo"
	$(SILENCER)$(OCAMLFIND) ocamlc $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I lib \
		-no-alias-deps \
		-o obj/test/hello/hello.cmo \
		-c src/test/hello/hello.ml
obj/test/hello/hello.cmx: $(LIB_INTERFACE) src/test/hello/hello.ml
	@$(ECHO) "Compiling test 'hello' cmx"
	$(SILENCER)$(OCAMLFIND) ocamlopt $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I lib \
		-no-alias-deps \
		-o obj/test/hello/hello.cmx \
		-c src/test/hello/hello.ml

test/hello/hello.wasm: src/test/hello/hello.wasm
	@$(ECHO) "Copying hello.wasm to the 'hello' test directory"
	$(SILENCER)cp src/test/hello/hello.wasm test/hello/hello.wasm

test/hello/hello: lib/Wasmer.cmxa obj/test/hello/hello.cmx test/hello/hello.wasm
	@$(ECHO) "Compiling test 'hello'"
	$(SILENCER)$(OCAMLFIND) ocamlopt $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I lib \
		-o test/hello/hello \
		-linkpkg \
		lib/Wasmer.cmxa \
		obj/test/hello/hello.cmx

obj/test/instance/instance.cmo: $(LIB_INTERFACE) src/test/instance/instance.ml
	@$(ECHO) "Compiling test 'instance' cmo"
	$(SILENCER)$(OCAMLFIND) ocamlc $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I lib \
		-no-alias-deps \
		-o obj/test/instance/instance.cmo \
		-c src/test/instance/instance.ml
obj/test/instance/instance.cmx: $(LIB_INTERFACE) src/test/instance/instance.ml
	@$(ECHO) "Compiling test 'instance' cmx"
	$(SILENCER)$(OCAMLFIND) ocamlopt $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I lib \
		-no-alias-deps \
		-o obj/test/instance/instance.cmx \
		-c src/test/instance/instance.ml

test/instance/instance: lib/Wasmer.cmxa obj/test/instance/instance.cmx
	@$(ECHO) "Compiling test 'instance'"
	$(SILENCER)$(OCAMLFIND) ocamlopt $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I lib \
		-o test/instance/instance \
		-linkpkg \
		lib/Wasmer.cmxa \
		obj/test/instance/instance.cmx

obj/examples/hello.cmo: $(LIB_INTERFACE) examples/hello.ml
	@$(ECHO) "Compiling example 'hello' cmo"
	$(SILENCER)$(OCAMLFIND) ocamlc $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I lib \
		-no-alias-deps \
		-o obj/examples/hello.cmo \
		-c examples/hello.ml
obj/examples/hello.cmx: $(LIB_INTERFACE) examples/hello.ml
	@$(ECHO) "Compiling example 'hello' cmx"
	$(SILENCER)$(OCAMLFIND) ocamlopt $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I lib \
		-no-alias-deps \
		-o obj/examples/hello.cmx \
		-c examples/hello.ml

examples/hello: lib/Wasmer.cmxa obj/examples/hello.cmx
	@$(ECHO) "Compiling example 'hello'"
	$(SILENCER)$(OCAMLFIND) ocamlopt $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I lib \
		-o examples/hello \
		-linkpkg \
		lib/Wasmer.cmxa \
		obj/examples/hello.cmx

obj/examples/instance.cmo: $(LIB_INTERFACE) examples/instance.ml
	@$(ECHO) "Compiling example 'instance' cmo"
	$(SILENCER)$(OCAMLFIND) ocamlc $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I lib \
		-no-alias-deps \
		-o obj/examples/instance.cmo \
		-c examples/instance.ml
obj/examples/instance.cmx: $(LIB_INTERFACE) examples/instance.ml
	@$(ECHO) "Compiling example 'instance' cmx"
	$(SILENCER)$(OCAMLFIND) ocamlopt $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I lib \
		-no-alias-deps \
		-o obj/examples/instance.cmx \
		-c examples/instance.ml

examples/instance: lib/Wasmer.cmxa obj/examples/instance.cmx
	@$(ECHO) "Compiling example 'instance'"
	$(SILENCER)$(OCAMLFIND) ocamlopt $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I lib \
		-o examples/instance \
		-linkpkg \
		lib/Wasmer.cmxa \
		obj/examples/instance.cmx
obj/examples/rust.cmo: $(LIB_INTERFACE) examples/rust.ml
	@$(ECHO) "Compiling example 'rust' cmo"
	$(SILENCER)$(OCAMLFIND) ocamlc $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I lib \
		-no-alias-deps \
		-o obj/examples/rust.cmo \
		-c examples/rust.ml
obj/examples/rust.cmx: $(LIB_INTERFACE) examples/rust.ml
	@$(ECHO) "Compiling example 'rust' cmx"
	$(SILENCER)$(OCAMLFIND) ocamlopt $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I lib \
		-no-alias-deps \
		-o obj/examples/rust.cmx \
		-c examples/rust.ml

examples/rust-wasm/target/wasm32-unknown-unknown/release/rust_integration.wasm:
	@$(ECHO) "Compiling the rust_integration.wasm for example 'rust'"
	$(SILENCER)cd examples; cd rust-wasm; cargo build --target=wasmtime-unknown-unknown --release

examples/rust: lib/Wasmer.cmxa obj/examples/rust.cmx examples/rust-wasm/target/wasm32-unknown-unknown/release/rust_integration.wasm
	@$(ECHO) "Compiling example 'rust'"
	$(SILENCER)$(OCAMLFIND) ocamlopt $(OCAMLFINDFLAGS) $(OCAMLFLAGS) \
		-I lib \
		-o examples/rust \
		-linkpkg \
		lib/Wasmer.cmxa \
		obj/examples/rust.cmx

# OCaml bug: the sigaltstack can't be changed by an external library
# or the program will crash on exit:
# https://github.com/ocaml/ocaml/issues/11489
# It is fixed by OCaml 4.14 (#11496) and should be fixed in OCaml 5.0.
# If the tests fails because of this, update your OCaml version.
check: $(TESTS)
	@$(ECHO) "Reminder: segmentation fault errors when exiting are known and an OCaml pre-4.14.1 bug."
	@$(ECHO); $(ECHO) Test: instance; cd test; cd instance; ./instance
	@$(ECHO); $(ECHO) Test: hello; cd test; cd hello; ./hello

examples: $(EXAMPLES)
	@$(ECHO) "Reminder: segmentation fault errors when exiting are known and an OCaml pre-4.14.1 bug."
	@$(ECHO); $(ECHO) Example: hello; cd examples; ./hello
	@$(ECHO); $(ECHO) Example: instance; cd examples; ./instance
	@$(ECHO); $(ECHO) Example: rust; cd examples; ./rust
.PHONY: examples

clean:
# Output
	$(RM) obj/lib/*
	$(SILENCER)touch obj/lib/.gitkeep
	$(RM) lib/*
	$(SILENCER)touch lib/.gitkeep
	
# Tests
	$(RM) obj/test/hello/* obj/test/instance/* obj/examples/*
	$(SILENCER)touch obj/test/hello/.gitkeep obj/test/instance/.gitkeep obj/examples/.gitkeep
	$(RM) $(TESTS) $(EXAMPLES)

install:
	$(SILENCER)if $(OCAMLFIND) query wasmer -qo -qe; then $(OCAMLFIND) remove wasmer; fi
	$(SILENCER)$(OCAMLFIND) install wasmer META lib/Wasmer.cmi lib/Wasmer.a lib/Wasmer.cma lib/Wasmer.cmxa lib/Wasmer.cmxs
