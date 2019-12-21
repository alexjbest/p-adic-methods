.PHONY:	clean clean-html all check deploy debug

XSLTPROC = xsltproc --timing --stringparam debug.datedfiles no --stringparam html.google-classic UA-48250536-1 # -v

docs:	docs/p-adic-methods.pdf p-adic-methods-pretty.xml p-adic-methods.xsl filter.xsl
	mkdir -p docs
	cd docs/; \
	$(XSLTPROC) ../p-adic-methods.xsl ../p-adic-methods-pretty.xml

p-adic-methods.tex:	p-adic-methods-pretty.xml p-adic-methods-latex.xsl filter.xsl
	$(XSLTPROC) -o p-adic-methods.tex p-adic-methods-latex.xsl p-adic-methods-pretty.xml

docs/p-adic-methods.pdf:	p-adic-methods.tex
	mkdir -p docs
	cd docs && latexmk -pdf -shell-escape -pdflatex="pdflatex -shell-escape -interaction=batchmode"  ../p-adic-methods.tex

docs/images/:	docs p-adic-methods-wrapper.xml
	mkdir -p docs/images
	../mathbook/script/mbx -vv -c latex-image -f svg -d ~/p-adic-methods/docs/images ~/p-adic-methods/p-adic-methods-wrapper.xml

p-adic-methods-wrapper.xml:	*.pug pug-plugin.json
	pug -O pug-plugin.json --extension xml p-adic-methods-wrapper.pug
	sed -i.bak -e 's/proofcase/case/g' p-adic-methods-wrapper.xml # Fix proofcase->case !! UGLY HACK, SAD
	rm p-adic-methods-wrapper.xml.bak

p-adic-methods-pretty.xml: p-adic-methods-wrapper.xml
	xmllint --pretty 2 p-adic-methods-wrapper.xml > p-adic-methods-pretty.xml

all:	docs docs/p-adic-methods.pdf

deploy: clean-html p-adic-methods-wrapper.xml docs
	cp p-adic-methods-wrapper.xml docs/p-adic-methods.xml
	./deploy.sh

debug:	*.pug pug-plugin.json
	pug -O pug-plugin.json --pretty --extension xml p-adic-methods-wrapper.pug

check:	p-adic-methods-pretty.xml
	jing ../mathbook/schema/pretext.rng p-adic-methods-pretty.xml
	#xmllint --xinclude --postvalid --noout --dtdvalid ../mathbook/schema/dtd/mathbook.dtd p-adic-methods-pretty.xml
	$(XSLTPROC) ../mathbook/schema/pretext-schematron.xsl p-adic-methods-pretty.xml

clean-html:
	rm -rf docs

clean:	clean-html
	rm -f p-adic-methods.md
	rm -f p-adic-methods*.tex
	rm -f p-adic-methods*.xml
