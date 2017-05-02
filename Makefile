openresty = openresty

md2html = pandoc --from markdown_github-hard_line_breaks --to html
md2txt = pandoc --from markdown_github-hard_line_breaks --to plain

md_files := $(wildcard blog/*/*/*.md)
html_files := $(patsubst %.md, templates/%.html, $(md_files))

gen_blogs_metadata_pl = ./util/gen-blogs-metadata.pl
blog_md_filter_pl = ./util/blog-md-filter.pl
tsv_files = blogs.tsv

.PHONY: all
all: html metadata

.PHONY: run
run:
	mkdir -p logs
	$(openresty) -p $$PWD -c conf/nginx.conf

reload: logs/nginx.pid all
	$(openresty) -p $$PWD -c conf/nginx.conf -t
	kill -HUP `cat $<`

stop: logs/nginx.pid
	$(openresty) -p $$PWD -c conf/nginx.conf -t
	kill -QUIT `cat $<`

.PHONY: deploy
deploy:
	ls $(tsv_files)
	psql -Ufonlang fonlang_com -f init.sql

.PHONY: initdb
initdb:
	psql -Ufonlang fonlang_com -f init.sql

.PHONY: gendata
gendata: html metadata

.PHONY: html
html: $(html_files)

templates/%.html: %.md
	mkdir -p templates/$(<D)
	$(md2html) --filter $(blog_md_filter_pl) $< --output $@

.PHONY: metadata
metadata:
	$(gen_blogs_metadata_pl)

.PHONY: clean
clean:
	rm -rf templates/blog *.tsv
