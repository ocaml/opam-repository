.PHONY: all

all: index
	@

index:
	git ls-tree --name-only -r HEAD > urls.txt

full:
	opam-mk-repo

clean:
	rm -rf archives tmp

