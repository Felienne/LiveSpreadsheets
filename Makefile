


TEMPLATES = templates-master/templates/markdown
ICLC_TEX = $(TEMPLATES)/pandoc/iclc.latex
ICLC_STY = $(TEMPLATES)/pandoc/iclc.sty
ICLC_HTML = $(TEMPLATES)/pandoc/iclc.html

all: paper.pdf paper.html

paper.html: paper.md references.bib
	pandoc --template=$(ICLC_HTML) --filter pandoc-citeproc --number-sections paper.md -o paper.html

paper.pdf: paper.md references.bib $(ICLC_TEX) $(ICLC_STY)
	(export TEXINPUTS=".:$(TEMPLATES):"; \
	pandoc --template=$(ICLC_TEX) \
		--filter pandoc-citeproc \
		--number-sections paper.md \
		-o paper.pdf)

paper.docx: paper.md references.bib
	pandoc --filter pandoc-citeproc --number-sections paper.md -o paper.docx






