# make sure you already ran pip install -r requirements.txt
#
# syntax
# pygmentize -S <style> -f <formatter> [-a <arg>] [-O <options>] [-P <option=value>]
# (pygmentize documentation is pretty scattered and confusing, but the "-a" will add other classes
# to the output)

cssfiles:
	pygmentize -L styles | grep \* | sed 's/\* //g' | sed 's/://g' | \
    	awk '{print "pygmentize -S "$$0" -O full,linenos=1 -f html -a .highlight > "$$0".css"}' | \
    	xargs -0 bash -c

clean:
	rm -rf *.css
