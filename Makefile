.PHONY: all

all: full
	@

index-only:
	opam-mk-repo -index

full:
	opam-mk-repo -all

PUBLISH_DIR=../opam.ocamlpro.com/
publish: index index-archive
	mkdir -p $(PUBLISH_DIR)
	rsync -avz --delete urls.txt index.tar.gz compilers archives descr opam url files $(PUBLISH_DIR)

clean:
	rm -rf archives

