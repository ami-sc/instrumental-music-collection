# ---- Project Settings --------------------------------------------------------

SSH_LOCATION  =
CELLAR_BOTTLE =
PROJECT_ID    =
INSTALL_DIR   =

CELLAR_TRACKS   = $(CELLAR_BOTTLE)/$(PROJECT_ID)/tracks
CELLAR_METADATA = $(CELLAR_BOTTLE)/$(PROJECT_ID)/metadata.csv
CELLAR_ARTWORK  = $(CELLAR_BOTTLE)/$(PROJECT_ID)/artwork.png

# ---- Makefile Settings -------------------------------------------------------

TRACK_LIST := $(shell ssh $(SSH_LOCATION) "ls $(CELLAR_TRACKS)")
FLAC_FILES := $(addprefix out/, $(addsuffix .flac, $(TRACK_LIST)))

GREEN = \e[32m
CYAN  = \e[36m
END   = \e[0m

.PHONY: all install clean setup

# ---- Pipeline ----------------------------------------------------------------

all: setup install

setup:
	@printf "%b %s\n" "$(CYAN)[ > ]$(END) Create working directory structure"
	@mkdir -p data/tracks
	@mkdir -p out/
	@printf "%b %s\n" "$(GREEN)[ ✓ ]$(END) Create working directory structure"

data/tracks/%.track:
	@printf "%b %s\n" "$(CYAN)[ > ]$(END) Download" "$(notdir $@)"
	@rsync -az -s "$(SSH_LOCATION):$(CELLAR_TRACKS)/$(basename $(notdir $@))" "$@"
	@printf "%b %s\n" "$(GREEN)[ ✓ ]$(END) Download" "$(notdir $@)"

data/metadata.csv:
	@printf "%b %s\n" "$(CYAN)[ > ]$(END) Download" "$(notdir $@)"
	@rsync -az -s "$(SSH_LOCATION):$(CELLAR_METADATA)" "$@"
	@printf "%b %s\n" "$(GREEN)[ ✓ ]$(END) Download" "$(notdir $@)"

data/artwork.png:
	@printf "%b %s\n" "$(CYAN)[ > ]$(END) Download" "$(notdir $@)"
	@rsync -az -s "$(SSH_LOCATION):$(CELLAR_ARTWORK)" "$@"
	@printf "%b %s\n" "$(GREEN)[ ✓ ]$(END) Download" "$(notdir $@)"

out/%.flac: data/tracks/%.track data/metadata.csv data/artwork.png
	@printf "%b %s\n" "$(CYAN)[ > ]$(END) Encode" "$(notdir $@)"
	@python src/encode.py \
		-t  $< \
		-id $(basename $(notdir $@)) \
		-m  data/metadata.csv \
		-a  data/artwork.png \
		-o  $@
	@printf "%b %s\n" "$(GREEN)[ ✓ ]$(END) Encode" "$(notdir $@)"

install: $(FLAC_FILES)
	@printf "%b %s\n" "$(CYAN)[ > ]$(END) Copy files to target directory"
	@python src/install.py \
		-td out/ \
		-m  data/metadata.csv \
		-d  "$(INSTALL_DIR)"
	@printf "%b %s\n" "$(GREEN)[ ✓ ]$(END) Copy files to target directory"

# ---- Cleanup -----------------------------------------------------------------

clean:
	@printf "%b %s\n" "$(CYAN)[ > ]$(END) Clean working directories"
	@rm -rf out/
	@rm -rf data/
	@printf "%b %s\n" "$(GREEN)[ ✓ ]$(END) Clean working directories"
