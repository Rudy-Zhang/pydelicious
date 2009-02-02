# pydelicious Makefile

## Local vars
API = src/__init__.py
TOOLS = tools/dlcs.py tools/optionparse.py #tools/cache.py
RST = README.rst HACKING.rst

DOC = $(RST:%.rst=doc/docbook/%.xml) #doc/docbook/index.xml 
	#$(API:%.py=doc/docbook/%.xml) $(TOOLS:tools/%.py=doc/docbook/%.xml) 
REF = $(DOC:doc/docbook/%.xml=doc/htmlref/%.html) \
	$(TOOLS:tools/%.py=doc/htmlref/%.html) $(API:src/%.py=doc/htmlref/%.html) 
MAN = doc/man/dlcs.man1.gz

TRGTS = $(REF)

# Docutils flags
DU_GEN = --traceback --no-generator --no-footnote-backlinks --date -i utf-8 -o utf-8
DU_READ = #--no-doc-title
DU_HTML = --no-compact-lists --footnote-references=superscript --cloak-email-addresses #--link-stylesheet --stylesheet=/style/default
DU_XML =


## Default target
.PHONY: help
help:
	@echo "No default build targets."
	@echo
	@echo " - install: install pydelicious API lib"
	@echo " - doc: build documentation targets"
	@echo " - clean: remove all build targets"
	@echo "	- test: run unittests, see test/main.py"
	@echo "	- test-server: run tests against delicious server"
	@echo "	- test-all: run all tests"


## Local targets
.PHONY: doc docbook install clean clean-make clean-setup all pre-dict clean-pyc test test-all test-server refresh-test-data

all: test doc

docbook: $(DOC)

doc: $(REF)
#$(DOC) 
#$(MAN)

#doc/htmlref/%.html: doc/docbook/%.xml # pydoc does text or html, no docbook
#doc/htmlref/dlcs.html: doc/docbook/dlcs.xml
#doc/man/dlcs.man1.gz: doc/docbook/dlcs.xml

test:
	python tests/main.py test_api

test-all:
	python tests/main.py

test-server:
	DLCS_DEBUG=1 python tests/main.py test_server

install:
	python setup.py install

clean: clean-setup clean-pyc clean-make

clean-setup:
	python setup.py clean

clean-make:
	rm -rf $(TRGTS) build/ pydelicious-*.zip

clean-pyc:
	-find -name '*.pyc' | xargs rm

clean-setuptools:
	# cleanup after setuptools..
	rm -rf dist build *.egg-info

refresh-test-data:
	# refetch cached test data to var/
	python tests/pydelicioustest.py refresh_test_data

zip: src/*.py Makefile $(RST) doc/htmlref var/* tests/* setup.py
	zip -9 pydelicious-`python -c "import src;print src.__version__"`.zip $^


%.xml: %.rst
	@rst2xml $(DU_GEN) $(DU_READ) $(DU_HTML) $< $@
	@echo "* $^ -> $@"

%.html: %.rst
	@rst2html $(DU_GEN) $(DU_READ) $(DU_HTML) $< $@
	@-tidy -q -m -wrap 0 -asxhtml -utf8 -i $@
	@echo "* $^ -> $@"

#doc/htmlref/HACKING.html doc/htmlref/README.html: README.html HACKING.html
doc/htmlref/README.html: README.html
doc/htmlref/HACKING.html: HACKING.html

doc/htmlref/%.html: %.html
	-mkdir doc/htmlref    
	mv *.html doc/htmlref/

doc/htmlref/__init__.html doc/htmlref/dlcs.html doc/htmlref/optionparse.html: $(API) $(TOOLS)
	-mkdir doc/htmlref    
	pydoc -w $^
	mv {dlcs,__init__,optionparse}.html doc/htmlref/

# vim:set noexpandtab:
