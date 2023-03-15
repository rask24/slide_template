# shell
SHELL = fish

# PDF filename
PDF_NAME = slide.pdf

# target and root file name
TARGET = index

# Directories
SOURCE_DIR = source
BUILD_DIR = build

# an directory containing images unser $SOURCE_DIR
IMAGES_DIR = images

# commands to compile document
LATEX = uplatex --shell-escape -halt-on-error
BIBTEX = upbibtex
DVIPDF = dvipdfmx
DVIPS = dvips

# source files
TEX_FILES = $(wildcard $(SOURCE_DIR)/*.tex)
BIB_FILES = $(wildcard $(SOURCE_DIR)/*.bib)
STY_FILES = $(wildcard $(SOURCE_DIR)/*.sty)
SVG_FILES = $(wildcard $(SOURCE_DIR)/$(IMAGES_DIR)/*.svg)
IMAGE_FILES = $(wildcard $(SOURCE_DIR)/$(IMAGES_DIR)/*.png) \
              $(wildcard $(SOURCE_DIR)/$(IMAGES_DIR)/*.pdf) \
              $(wildcard $(SOURCE_DIR)/$(IMAGES_DIR)/*.eps) \
              $(wildcard $(SOURCE_DIR)/$(IMAGES_DIR)/*.jpg) \
              $(wildcard $(SOURCE_DIR)/$(IMAGES_DIR)/*.jpeg)

# generated files
LINKED_IMAGE_FILES = $(addprefix $(BUILD_DIR)/$(IMAGES_DIR)/,$(notdir $(IMAGE_FILES)))
EPS_FILES = $(addprefix $(BUILD_DIR)/$(IMAGES_DIR)/,$(notdir $(SVG_FILES:%.svg=%.pdf)))
LINKED_BIB_FILES = $(addprefix $(BUILD_DIR)/,$(notdir $(BIB_FILES)))
LINKED_TEX_FILES = $(addprefix $(BUILD_DIR)/,$(notdir $(TEX_FILES)))
LINKED_STY_FILES = $(addprefix $(BUILD_DIR)/,$(notdir $(STY_FILES)))

.DEFAULT_GOAL = pdf

.PHONY : pdf
pdf : $(BUILD_DIR)/$(TARGET).pdf
$(BUILD_DIR)/$(TARGET).pdf : $(BUILD_DIR)/$(TARGET).dvi $(TEX_FILES) $(EPS_FILES)
	cd $(BUILD_DIR) && \
	$(DVIPDF) $(TARGET)
	cp $(BUILD_DIR)/index.pdf ./$(PDF_NAME)

.PHONY : ps
ps : $(BUILD_DIR)/$(TARGET).ps
$(BUILD_DIR)/$(TARGET).ps : $(BUILD_DIR)/$(TARGET).dvi $(TEX_FILES) $(EPS_FILES)
	cd $(BUILD_DIR) && \
	$(DVIPS) $(TARGET)

$(BUILD_DIR)/$(TARGET).dvi : $(BUILD_DIR)/$(TARGET).bbl $(BUILD_DIR)/$(TARGET).aux
	cd $(BUILD_DIR) && \
	$(LATEX) $(TARGET) && \
	$(LATEX) $(TARGET) >/dev/null

$(BUILD_DIR)/$(TARGET).bbl : $(BUILD_DIR)/$(TARGET).aux $(LINKED_BIB_FILES)
ifneq ($(strip $(BIB_FILES)),)
	cd $(BUILD_DIR) && \
	$(BIBTEX) $(TARGET)
endif

$(BUILD_DIR)/$(TARGET).aux : $(BUILD_DIR)/ $(LINKED_TEX_FILES) $(LINKED_IMAGE_FILES) $(LINKED_STY_FILES) $(TEX_FILES) $(EPS_FILES)
	cd $(BUILD_DIR) && \
	$(LATEX) $(TARGET)

$(BUILD_DIR)/ :
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/$(IMAGES_DIR)/ :
	mkdir -p $(BUILD_DIR)/$(IMAGES_DIR)

$(BUILD_DIR)/% : $(SOURCE_DIR)/% $(BUILD_DIR)/
	ln -fs $(shell realpath "$<") "$@"

$(BUILD_DIR)/$(IMAGES_DIR)/% : $(SOURCE_DIR)/$(IMAGES_DIR)/% $(BUILD_DIR)/$(IMAGES_DIR)/
	ln -fs $(shell realpath "$<") "$@"

$(BUILD_DIR)/$(IMAGES_DIR)/%.pdf : $(SOURCE_DIR)/$(IMAGES_DIR)/%.svg $(BUILD_DIR)/$(IMAGES_DIR)/
	inkscape -z -D --file="$<" --export-pdf="$@"

.PHONY : clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY : re
re: clean pdf

.PHONY : ar
ar: lib/archive_bin
	mkdir -p ./archive/tmp
	cp build/index.pdf archive/tmp/
	cp -r source archive/tmp
	./lib/archive_bin
	rm -rf $(BUILD_DIR)
	rm -rf *.pdf

lib/archive_bin: lib/archive.cpp
	g++ $< -o $@

.PHONY : help
help:
	@echo "make dvi"
	@echo "        Make DVI file from tex documents."
	@echo "make pdf"
	@echo "        Make PDF file from DVI file."
	@echo "make ps"
	@echo "        Make PS file from DVI file."
	@echo "make clean"
	@echo "        Clean build directory."
	@echo "make re"
	@echo "        clean and pdf"
