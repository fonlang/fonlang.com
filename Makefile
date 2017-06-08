openresty = openresty

md2html = pandoc --no-highlight --from markdown --to html
md2txt = pandoc --to plain

md_files := $(wildcard blog/*/*/*.md)
html_files := $(patsubst %.md, templates/%.html, $(md_files))

handle_blogs_pl = ./util/handle-blogs.pl
blog_md_filter_pl = ./util/blog-md-filter.pl
tsv_files = posts.tsv

.PHONY: all
all: html handle_blogs

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
gendata: html handle_blogs 

.PHONY: html
html: $(html_files)

templates/%.html: %.md
	mkdir -p templates/$(<D)
	$(md2html) $< --output $@
	#$(md2html) --filter $(blog_md_filter_pl) $< --output $@

.PHONY: handle_blogs
handle_blogs:
	$(handle_blogs_pl)

.PHONY: clean
clean:
	rm -rf templates/*.tsv
