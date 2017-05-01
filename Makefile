md2html = pandoc --from markdown_github-hard_line_breaks --to html
md2txt = pandoc --from markdown_github-hard_line_breaks --to plain

md_files := $(wildcard blog/*/*/*.md)
html_files := $(patsubst %.md, templates/%.html, $(md_files))

gen_blogs_metadata_pl = ./util/gen-blogs-metadata.pl
blog_md_filter_pl = ./util/blog-md-filter.pl

.PHONY: all
all: html metadata initdb

.PHONY: html
html: $(html_files)

templates/%.html: %.md
	mkdir -p templates/$(<D)
	$(md2html) --filter $(blog_md_filter_pl) $< --output $@

.PHONY: metadata
metadata:
	$(gen_blogs_metadata_pl)

.PHONY: initdb
initdb:
	psql -d fonlang_com -U fonlang -f init.sql

.PHONY: clean
clean:
	rm -rf templates/blog *.tsv
