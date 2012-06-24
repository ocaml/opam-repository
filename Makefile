.PHONY: all

all: index
	@

index:
	git ls-tree -r HEAD | awk '{print "0o"substr($$1,length($$1)-3,4) " " $$4}' > urls.txt

full:
	opam-mk-repo

clean:
	rm -rf archives tmp

