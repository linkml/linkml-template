SCHEMA_NAME = my_schema
TGTS = graphql jsonschema docs shex owl rdf csv graphql python
#EXTS = _datamodel.py .graphql .schema.json .owl.ttl .ttl -docs .shex
SRC_DIR = src
SCHEMA_DIR = $(SRC_DIR)/schema
SCHEMA_SRC = $(SCHEMA_DIR)/$(SCHEMA_NAME).linkml.yaml

all: gen deploy
gen: $(patsubst %,gen-%,$(TGTS))
clean:
	rm -rf target/
	rm -rf docs/
echo:
	echo $(patsubst %,gen-%,$(TGTS))

test: all

install:
	. environment.sh
	pip install -r requirements.txt

tdir-%:
	mkdir -p target/$*
docs:
	mkdir $@

deploy: $(patsubst %,deploy-%,$(TGTS))
deploy-%: gen-%
	cp -pr target/$* .

# Generate documentation ready for mkdocs
gen-docs: target/docs/index.md
.PHONY: gen-docs
target/docs/%.md: $(SCHEMA_SRC) tdir-docs
	gen-markdown --dir target/docs $<
deploy-docs: gen-docs
	cp -pr target/docs .

gen-owl: target/owl/$(SCHEMA_NAME).owl.ttl
.PHONY: gen-owl
target/owl/%.owl.ttl: $(SCHEMA_SRC) tdir-owl
	gen-owl $< > $@

gen-python: target/python/$(SCHEMA_NAME).py
.PHONY: gen-owl
target/python/%.py: $(SCHEMA_SRC)  tdir-python
	gen-py-classes $< > $@

gen-graphql:target/graphql/$(SCHEMA_NAME).graphql 
target/graphql/%.graphql: $(SCHEMA_SRC) tdir-graphql
	gen-graphql $< > $@

gen-jsonschema: target/jsonschema/$(SCHEMA_NAME).schema.json
target/jsonschema/%.schema.json: $(SCHEMA_SRC) tdir-jsonschema
	gen-json-schema -t transaction $< > $@

gen-shex: target/shex/$(SCHEMA_NAME).shex
target/shex/%.shex: $(SCHEMA_SRC) tdir-shex
	gen-shex $< > $@

gen-csv:  target/csv/$(SCHEMA_NAME).csv
target/csv/%.csv: $(SCHEMA_SRC) tdir-csv
	gen-csv $< > $@

gen-rdf: target/rdf/$(SCHEMA_NAME).ttl
target/rdf/%.ttl: $(SCHEMA_SRC) tdir-rdf
	gen-rdf $< > $@

gen-linkml: target/linkml/$(SCHEMA_NAME).yaml
target/linkml/%.yaml: $(SCHEMA_SRC) tdir-limkml
	cp $< > $@

docserve:
	mkdocs serve

gh-deploy:
	mkdocs gh-deploy
