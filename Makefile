.PHONY: all

all: index index-archive full
	@

index:
	git ls-tree -r HEAD | awk '{print "0o"substr($$1,length($$1)-3,4) " " $$4}' > urls.txt

index-archive:
	tar cz opam descr url > index.tar.gz

full:
	opam-mk-repo

PUBLISH_DIR=../mirage.github.com/opam/
publish: index
	mkdir -p $(PUBLISH_DIR)
	rsync -avz --delete urls.txt archives descr opam url files $(PUBLISH_DIR)

clean:
	rm -rf archives tmp

